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

var tune0 = tuneInformation(tuneName: "Cloud 9", artistName: "Itro & Tobu", tunePath: Bundle.main.path(forResource: "Itro & Tobu-Cloud 9", ofType:"mp3")!)
var tune1 = tuneInformation(tuneName: "Sthlm Sunset", artistName: "Ehrling", tunePath: Bundle.main.path(forResource: "Ehrling-Sthlm Sunset", ofType:"mp3")!)
var tune2 = tuneInformation(tuneName: "Sunburst", artistName: "Tobu & Itro", tunePath: Bundle.main.path(forResource: "Tobu & Itro-Sunburst", ofType:"mp3")!)
var tune3 = tuneInformation(tuneName: "Candyland", artistName: "Tobu", tunePath: Bundle.main.path(forResource: "Tobu-Candyland", ofType:"mp3")!)
var tune4 = tuneInformation(tuneName: "Dance With Me", artistName: "Ehrling", tunePath: Bundle.main.path(forResource: "Ehrling-Dance With Me", ofType:"mp3")!)

// 再生する audio ファイルのパスを取得
var playList = [tune0, tune1, tune2, tune3, tune4]

// 選択された行番号を保存する変数
var selectedIndex:Int!

class Best30PlayListViewController: UIViewController ,UITableViewDelegate ,UITableViewDataSource {

    @IBOutlet weak var playListTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        playListTableView.delegate = self
        playListTableView.dataSource = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // TableView行数を決定
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return playList.count
    }
    
    // 表示する中身の設定　１行毎のセルの設定
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // セルのインスタンス化　文字列を表示するCell
        let cell: UITableViewCell! = tableView.dequeueReusableCell(withIdentifier: "tableviewcell", for: indexPath)
        cell.textLabel?.text = playList[indexPath.row].tuneName
        return cell
    }
    
    // セルをタップしたら発動する

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        selectedIndex = indexPath.row
        // セグエの名前を指定して画面遷移を発動
        performSegue(withIdentifier: "segue1", sender: nil)
    }
    
    // セグエを使って画面遷移しているときに発動
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // 遷移先に情報を渡す処理
        //次の画面のインスタンスを生成
        let dvc:ViewController = segue.destination as! ViewController
        
        // 次の画面のプロパティ passedIndexに選択された行番号を渡す
        dvc.recievedIndex = selectedIndex
        
    }
}
