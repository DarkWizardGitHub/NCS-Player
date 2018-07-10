//
//  Best30PlayListViewController.swift
//  NCS Player
//
//  Created by Dark on 2018/06/03.
//  Copyright © 2018年 Dark. All rights reserved.
//

import UIKit
import AVFoundation

class MyPlayListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    // ユーザーデフォルトインスタンス(参照)
    // let userDefaults = UserDefaults.standard

    // CoreData操作クラスインスタンス
    let coreDataManager: CoreDataManager<String> = CoreDataManager<String>(setEntityName: GlobalVariableManager.shared.coreDataEntityName, attributeNames: GlobalVariableManager.shared.coreDataAttributes)

    // プレイリスト用配列(2次元配列)
    // [[String]] = [] でも同義
//     var myPlayList: Array<Array<String>> = []
    
    // Sectionのタイトル
    let sectionTitle: NSArray = ["   My Playlist"]
    
    @IBOutlet weak var playListTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.playListTableView.delegate = self
        self.playListTableView.dataSource = self
        
        // TableView並べ替えに必要
        self.playListTableView.isEditing = true
        // Cellをタップ選択できるようにする
        self.playListTableView.allowsSelectionDuringEditing = true
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        // UserDefaultsからMyPlayListデータを取得
        // as! [[String]] = [] でも同義
        // 2次元配列の為ダウンキャストも2次元配列にする
        // myPlayList = userDefaults.object(forKey: "myPlayList") as! Array<Array<String>>
        
        // CoreDataからMyPlayListデータを取得
        // 2次元配列の為ダウンキャストも2次元配列にする
//        myPlayList = (coreDataManager.readAll() as! Array<Array<Any>>).filter{ $0[4] as! Bool == true }
        GlobalVariableManager.shared.playList = coreDataManager.readAll() as! Array<Array<String>>
        playListTableView.reloadData()
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
        label.backgroundColor = UIColor(red: 66/255, green: 66/255, blue: 66/255, alpha: 1)
        return label
    }
    
    // TableViewのセルの数を指定
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return GlobalVariableManager.shared.playList.count
    }
    
    // 1行毎のセルの要素を設定する(表示する中身の設定)
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // セルのインスタンス化　文字列を表示するCell
        let cell: UITableViewCell! = tableView.dequeueReusableCell(withIdentifier: "myplaylistviewtableviewcell", for: indexPath)
        cell.textLabel?.text = GlobalVariableManager.shared.playList[indexPath.row][0]
        return cell
    }

//    //    今後の拡張機能を見据えて残す
//    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
//        let deleteButton: UITableViewRowAction = UITableViewRowAction(style: .normal, title: "DELETE") { (action, index) -> Void in
//
//            // データベースから要素を削除
//            self.coreDataManager.delete(attribute: GlobalVariableManager.shared.coreDataAttributes[0], relationalOperator: "=", placeholder: "%@", targetValue: GlobalVariableManager.shared.playList[indexPath.row][0])
//            // removeで配列から要素削除
//            GlobalVariableManager.shared.playList.remove(at: indexPath.row)
//            // deleteRowsでセルから要素を削除
//            tableView.deleteRows(at: [indexPath], with: .fade)
//        }
//        // Deleteボタン背景色設定
//        deleteButton.backgroundColor = UIColor(red: 66/255, green: 66/255, blue: 66/255, alpha: 1)
//        return [deleteButton]
//    }
    
    // セルを動かせるように設定
    // Asks the data source whether a given row can be moved to another location in the table view
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    // セル入れ替え時の処理
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        
        // 移動された要素(Array<String>型)を取得
        let changedElement = GlobalVariableManager.shared.playList[sourceIndexPath.row]
        
        // 元の位置の要素(Array<String>型)を配列から削除
        // 配列内の指定indexの要素(Array<String>型)を削除
        GlobalVariableManager.shared.playList.remove(at: sourceIndexPath.row)
        
        // 移動先の位置に要素を配列に挿入
        GlobalVariableManager.shared.playList.insert(changedElement, at:destinationIndexPath.row)
        
        // CoreData初期化
        coreDataManager.deleteAll()
        
        // 変更後の曲順(要素順)でMyPlaylist配列をCoreDataへ保存
        GlobalVariableManager.shared.playList.forEach {
            coreDataManager.create(values: $0)
        }
    }
    
    // Asks the delegate for the editing style of a row at a particular location in a table view
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        return .none
    }
    
    // セル並べ替え時にインデントさせないように設定
    // Asks the delegate whether the background of the specified row should be indented while the table view is in editing mode
    func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    // セルをタップしたら遷移する
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        // 遷移元のViewController名
        GlobalVariableManager.shared.callerViewName = "MyPlayListViewController"
        // 選択した曲番号(配列のインデックス)を格納
        GlobalVariableManager.shared.tuneIndex = indexPath.row
        // セグエの名前を指定して画面遷移を発動
        performSegue(withIdentifier: "segue2", sender: nil)
    }
}


