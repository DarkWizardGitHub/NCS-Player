//
//  SettingsViewController.swift
//  NCS Player
//
//  Created by Dark on 2018/07/06.
//  Copyright © 2018年 Dark. All rights reserved.
//

import UIKit
import AVFoundation

class SettingsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    // ユーザーデフォルトインスタンス(参照)
    // let userDefaults = UserDefaults.standard
    
    // CoreData操作クラスインスタンス
    //    let coreDataManager: CoreDataManager<String> = CoreDataManager<String>(setEntityName: GlobalVariableManager.shared.coreDataEntityName, attributeNames: GlobalVariableManager.shared.coreDataAttributes)
    
    // plistファイルパス
    let plistFilePath = Bundle.main.path(forResource: "SettingOptions", ofType:"plist")
    
    // SettingOptions用配列(2次元配列)
    // [[String]] = [] でも同義
    var settingOptionList: Array<Array<String>> = []
    
    // Sectionのタイトル
    let sectionTitle: NSArray = ["General", "Special Thanks"]
    
    // Outlet接続
    @IBOutlet weak var settingsTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.settingsTableView.delegate = self
        self.settingsTableView.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.settingOptionList = NSArray(contentsOfFile: plistFilePath!) as! Array<Array<String>>
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // Section数
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.sectionTitle.count
    }
    
    // Sectioのタイトル
    //    func tableView(_ tableView: UITableView,
    //                   titleForHeaderInSection section: Int) -> String? {
    //        return sectionTitle[section] as? String
    //    }
    
    // Sectioのタイトル
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let label: UILabel = UILabel()
        label.text = "   " + (sectionTitle[section] as! String)
        // UIcolorのRGB値の引数に255で割った値を直接渡す
        label.textColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 1)
        label.backgroundColor = UIColor(red: 66/255, green: 66/255, blue: 66/255, alpha: 1)
        return label
    }

    // TableViewのセルの数を指定
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // prefix(1)で先頭の文字を抽出、uppercased()で小文字も大文字に強制変換し、各アルファベット(Section名と同じ)と比較
        return self.settingOptionList.filter{ $0[0] == sectionTitle[section] as! String }.count
    }

    // 1行毎のセルの要素を設定する(表示する中身の設定)
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // セルのインスタンス化　文字列を表示するCell
        let cell: UITableViewCell! = tableView.dequeueReusableCell(withIdentifier: "settingsviewtableviewcell", for: indexPath)
        cell.textLabel?.text = self.settingOptionList.filter{ $0[0] == sectionTitle[indexPath.section] as! String }[indexPath.row][1]
        return cell
    }

    // セルをタップしたら遷移する
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        // セグエの名前を指定して画面遷移を発動
        
        // cellForRow(at:) -> the table cell at the specified index path
        // IndexPath -> A list of indexes that together represent the path to a specific location in a tree of nested arrays
        switch settingsTableView.cellForRow(at: IndexPath(row: indexPath.row, section: indexPath.section))?.textLabel?.text {
            case "About NCS Player":
                performSegue(withIdentifier: "segue3", sender: nil)
//            case "User Policy":
//                performSegue(withIdentifier: "segue4", sender: nil)
            default:
                break
        }
    }
}
