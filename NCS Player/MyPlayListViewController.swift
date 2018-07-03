//
//  Best30PlayListViewController.swift
//  NCS Player
//
//  Created by Dark on 2018/06/03.
//  Copyright © 2018年 Dark. All rights reserved.
//

import UIKit
import AVFoundation

//        実装すること
//        順序を変更する機能(タップしながらズラすような感じ、もしくは上下移動か)

class MyPlayListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    // ユーザーデフォルトインスタンス(参照)
    // let userDefaults = UserDefaults.standard

    // CoreData操作クラスインスタンス
    let coreDataManager: CoreDataManager<String> = CoreDataManager<String>(setEntityName: GlobalVariableManager.shared.coreDataEntityName, attributeNames: GlobalVariableManager.shared.coreDataAttributes)

    // プレイリスト用配列(2次元配列)
    // [[String]] = [] でも同義
//     var myPlayList: Array<Array<String>> = []
    
    // Sectionのタイトルr
    let sectionTitle: NSArray = ["   My Playlist"]
    
    @IBOutlet weak var playListTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.playListTableView.delegate = self
        self.playListTableView.dataSource = self
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
//        ***Debug用/初期リストUserDefaults格納***
//        var hoge = [["Cloud 9", "Itro & Tobu", "Itro & Tobu-Cloud 9", "mp3"],["Sthlm Sunset", "Ehrling", "Ehrling-Sthlm Sunset", "mp3"],["Sunburst", "Tobu & Itro", "Tobu & Itro-Sunburst", "mp3"],["Candyland", "Tobu", "Tobu-Candyland", "mp3"],["Dance With Me", "Ehrling", "Ehrling-Dance With Me", "mp3"]]
//        userDefaults.set(hoge, forKey: "myPlayList")
//        userDefaults.synchronize()
//        ***Debug用/初期リスト格納***
        
        
//        ***Debug用/初期リストCoreData格納***
//        var hoge = [["Cloud 9", "Itro & Tobu", "Itro & Tobu-Cloud 9", "mp3", true],["Sthlm Sunset", "Ehrling", "Ehrling-Sthlm Sunset", "mp3", false],["Sunburst", "Tobu & Itro", "Tobu & Itro-Sunburst", "mp3", false],["Candyland", "Tobu", "Tobu-Candyland", "mp3", false],["Dance With Me", "Ehrling", "Ehrling-Dance With Me", "mp3", false],["Bay Breeze", "FortyThr33", "FortyThr33-Bay Breeze", "mp3", false],["Good For You", "THBD", "THBD-Good For You", "mp3", false],["Hope", "Tobu", "Tobu-Hope", "mp3", false],["Fade", "Alan Walker", "Alan Walker-Fade", "mp3", false],["All I Need", "Ehrling", "Ehrling-All I Need", "mp3", false],["Champagne Ocean", "Ehrling", "Ehrling-Champagne Ocean", "mp3", true]]
//            var hoge = [["All I Need", "Ehrling", "Ehrling-All I Need", "mp3"]]
//         UserdefaultsでmyPlayListを取得した場合、CoreDataManagerクラス側の引数が1次元配列の為foreachで回す
//                 hoge.forEach {
//                    coreDataManager.create(values: $0 as! [String])
//                 }
        // ***Debug用/初期リストCoreData格納***
        
        
        // UserDefaultsからMyPlayListデータを取得
        // as! [[String]] = [] でも同義
        // 2次元配列の為ダウンキャストも2次元配列にする
        // myPlayList = userDefaults.object(forKey: "myPlayList") as! Array<Array<String>>
        
        // CoreDataからMyPlayListデータを取得
        // 2次元配列の為ダウンキャストも2次元配列にする
//        myPlayList = (coreDataManager.readAll() as! Array<Array<Any>>).filter{ $0[4] as! Bool == true }
        GlobalVariableManager.shared.playList = coreDataManager.readAll() as! Array<Array<String>>
//        print("マイプレイリスト\(GlobalVariableManager.shared.myPlayList)")
//        こいつを入れないとGlobalVariableManager.shared.myPlayListを更新してもテーブルセルの更新が行われない
//        おかゆさんに質問する事
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
        label.backgroundColor = UIColor(red: 96/255, green: 96/255, blue: 96/255, alpha: 1)
//        何故か色が濃くなる
//        label.backgroundColor = UIColor(red: 32/255, green: 32/255, blue: 32/255, alpha: 1)
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
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let deleteButton: UITableViewRowAction = UITableViewRowAction(style: .normal, title: "DELETE") { (action, index) -> Void in

            // データベースから要素を削除
            self.coreDataManager.delete(attribute: GlobalVariableManager.shared.coreDataAttributes[0], relationalOperator: "=", placeholder: "%@", targetValue: GlobalVariableManager.shared.playList[indexPath.row][0])
            // removeで配列から要素削除
            GlobalVariableManager.shared.playList.remove(at: indexPath.row)
            // deleteRowsでセルから要素を削除
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
        // Deleteボタン背景色設定
        deleteButton.backgroundColor = UIColor(red: 32/255, green: 32/255, blue: 32/255, alpha: 1)
        return [deleteButton]
    }
    
    // セルをタップしたら遷移する
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        // 遷移元のViewController名
        GlobalVariableManager.shared.callerViewName = "MyPlayListViewController"
        // 選択した曲番号(配列のインデックス)を格納
        GlobalVariableManager.shared.tuneIndex = indexPath.row
        // セグエの名前を指定して画面遷移を発動
        performSegue(withIdentifier: "segue1", sender: nil)
    }

}
