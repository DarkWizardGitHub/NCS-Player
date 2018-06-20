//
//  Best30PlayListViewController.swift
//  NCS Player
//
//  Created by Dark on 2018/06/03.
//  Copyright © 2018年 Dark. All rights reserved.
//

import UIKit
import AVFoundation

struct tuneInformation {
    var tuneName: String
    var artistName: String
    var tunePath: String?
}




//ユーザーリストはiOSの記憶領域に保存するべきか？




var tune0 = tuneInformation(tuneName: "Cloud 9", artistName: "Itro & Tobu", tunePath: Bundle.main.path(forResource: "Itro & Tobu-Cloud 9", ofType:"mp3")!)
var tune1 = tuneInformation(tuneName: "Sthlm Sunset", artistName: "Ehrling", tunePath: Bundle.main.path(forResource: "Ehrling-Sthlm Sunset", ofType:"mp3")!)
var tune2 = tuneInformation(tuneName: "Sunburst", artistName: "Tobu & Itro", tunePath: Bundle.main.path(forResource: "Tobu & Itro-Sunburst", ofType:"mp3")!)
var tune3 = tuneInformation(tuneName: "Candyland", artistName: "Tobu", tunePath: Bundle.main.path(forResource: "Tobu-Candyland", ofType:"mp3")!)
var tune4 = tuneInformation(tuneName: "Dance With Me", artistName: "Ehrling", tunePath: Bundle.main.path(forResource: "Ehrling-Dance With Me", ofType:"mp3")!)

// 再生する audio ファイルのパスを取得
var playList = [tune0, tune1, tune2, tune3, tune4]

class RecommendedPlayListViewController: UIViewController ,UITableViewDelegate ,UITableViewDataSource {
    
    let coreDataManager: CoreDataManager = CoreDataManager(setEntityName: GlobalVariableManager.shared.coreDataEntityName, attributeNames: GlobalVariableManager.shared.coreDataAttributes)
    
    // Sectionのタイトル
    let sectionTitle: NSArray = ["RecommendedPlayList"]
    
    @IBOutlet weak var playListTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.playListTableView.delegate = self
        self.playListTableView.dataSource = self
        
        
//        聞くこと
//        セクションのフォントサイズとカラー変更方法
//        リストの枠が一部広くなる理由
        
//        実装すること
//        リストから削除する機能
//        順序を変更する機能(タップしながらズラすような感じ、もしくは上下移動か)
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
        label.text = sectionTitle[section] as! String
        // UIcolorのRGB値は、256段階ではなく、0~1.0までの値で指定
        // UIcolorのRGB値の引数に255で割った値を直接渡す
        label.textColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 1)
        label.backgroundColor = UIColor(red: 32/255, green: 32/255, blue: 32/255, alpha: 1)
        return label
    }
    
    // TableViewのセルの数を指定
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return playList.count
    }
    
    // 1行毎のセルの要素を設定する(表示する中身の設定)
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // セルのインスタンス化　文字列を表示するCell
        let cell: UITableViewCell! = tableView.dequeueReusableCell(withIdentifier: "tableviewcell", for: indexPath)
        cell.textLabel?.text = playList[indexPath.row].tuneName
        return cell
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        // removeで配列から要素削除、deleteRowsでセルから要素を削除
        let deleteButton: UITableViewRowAction = UITableViewRowAction(style: .normal, title: "DELETE") { (action, index) -> Void in
            playList.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            // データベースの要素を削除する機能を追加する
            
//            create処理OK
//            let hoge: [String] = ["c","cc","ccc"]
//            self.coreDataManager.create(values: hoge)
        
//            read(sort)処理OK
//            self.coreDataManager.sortRead(attribute: GlobalVariableManager.shared.coreDataAttributes[0], ascending: true, numberOfLimit: 4)
            
//            read(predicate)処理OK
//            self.coreDataManager.predicateRead(attribute: GlobalVariableManager.shared.coreDataAttributes[0], placeholder: "%@", string: "b", numberOfLimit: 3)
            
//            update処理OK
//            データがない場合にエラーになるので、エラー処理考えないとバグって寒い
            let hoge: [String] = ["d","dd","ddd"]
            self.coreDataManager.update(attribute: GlobalVariableManager.shared.coreDataAttributes[0], placeholder: "%@", string: "c", values: hoge)
            
//            delete処理OK
//            self.coreDataManager.delete(attribute: GlobalVariableManager.shared.coreDataAttributes[0], placeholder: "%@", string: "tunename")

             

        }
        deleteButton.backgroundColor = UIColor(red: 32/255, green: 32/255, blue: 32/255, alpha: 1)
        
        return [deleteButton]
    }
    
    // セルをタップしたら遷移する
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        GlobalVariableManager.shared.tuneIndex = indexPath.row
        // セグエの名前を指定して画面遷移を発動
        performSegue(withIdentifier: "segue1", sender: nil)
    }

}
