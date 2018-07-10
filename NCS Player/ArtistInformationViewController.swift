//
//  ArtistInformationViewController.swift
//  NCS Player
//
//  Created by Dark on 2018/07/04.
//  Copyright © 2018年 Dark. All rights reserved.
//

import UIKit
import AVFoundation

class ArtistInformationViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    // ユーザーデフォルトインスタンス(参照)
    // let userDefaults = UserDefaults.standard
    
    // CoreData操作クラスインスタンス
//    let coreDataManager: CoreDataManager<String> = CoreDataManager<String>(setEntityName: GlobalVariableManager.shared.coreDataEntityName, attributeNames: GlobalVariableManager.shared.coreDataAttributes)
    
    // plistファイルパス
    let plistFilePath = Bundle.main.path(forResource: "Artists", ofType:"plist")
    
    // ArtistInformation用配列(2次元配列)
    // [[String]] = [] でも同義
    var artistList: Array<Array<String>> = []
    
    // Sectionのタイトル
    let sectionTitle: NSArray = ["A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z"]
    
    @IBOutlet weak var artistInformationTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.artistInformationTableView.delegate = self
        self.artistInformationTableView.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.artistList = NSArray(contentsOfFile: plistFilePath!) as! Array<Array<String>>
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
        return self.artistList.filter{ $0[0].prefix(1).uppercased() == sectionTitle[section] as! String }.count
    }
    
    // 1行毎のセルの要素を設定する(表示する中身の設定)
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // セルのインスタンス化　文字列を表示するCell
        let cell: SubArtistInformationViewController! = tableView.dequeueReusableCell(withIdentifier: "artistinformationviewtableviewcell", for: indexPath) as! SubArtistInformationViewController
        
//        上でダウンキャストもしているのに何故ダメなのか？
//        Subクラス側でindexPathを使用したいため、どうやったら引き渡せるか
//        cell.hoge = indexPath
//        print("親\(indexPath)")
        cell.textLabel?.text = self.artistList.filter{ $0[0].prefix(1).uppercased() == sectionTitle[indexPath.section] as! String }[indexPath.row][0]
        cell.jumpToWebButton.layer.cornerRadius = 5.0
        cell.jumpToYoutubeButton.layer.cornerRadius = 5.0
        return cell
    }
    
    // セルをタップしたら遷移する
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    }
}
