//
//  SearchViewController.swift
//  NCS Player
//
//  Created by Dark on 2018/06/03.
//  Copyright © 2018年 Dark. All rights reserved.
//

//やる事
//ソート機能、曲名OKとアーティスト名YET
//オートレイアウト見直し、色が濃くなる事象解決
//ストリーミング再生
//ローカルストレージ再生
//設定兼、自己サイトリンク兼、課金系機能制限
//ノーマルモード時に曲名変わらない？再現できず

import UIKit
import AVFoundation

class SearchViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    
    // ユーザーデフォルトインスタンス(参照)
    // let userDefaults = UserDefaults.standard
    
    // CoreData操作クラスインスタンス
    let coreDataManager: CoreDataManager<String> = CoreDataManager<String>(setEntityName: GlobalVariableManager.shared.coreDataEntityName, attributeNames: GlobalVariableManager.shared.coreDataAttributes)
    
    // plistファイルパス
    let plistFilePath = Bundle.main.path(forResource: "Tunes", ofType:"plist")
    
    // 検索結果用配列(2次元配列)
    var searchedResultList: Array<Array<Any>> = []

    // Outlet接続
    @IBOutlet weak var tuneSearchBar: UISearchBar!
    @IBOutlet weak var searchedResultsTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.searchedResultsTableView.delegate = self
        self.searchedResultsTableView.dataSource = self
        // デリゲート先を自分に設定
        self.tuneSearchBar.delegate = self
        // 何も入力されていなくてもReturnキーを押せるように設定
        self.tuneSearchBar.enablesReturnKeyAutomatically = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // sorted{}内で第一引数$0と第二引数$1の先頭の要素(曲名)を比較しアルファベット順に並び替え
        searchedResultList = (NSArray(contentsOfFile: plistFilePath!) as! Array<Array<Any>>).sorted{ ($0[0] as! String) < ($1[0] as! String) }
        GlobalVariableManager.shared.playList = coreDataManager.readAll() as! Array<Array<String>>
        searchedResultsTableView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning() 
    }
    
    // Section数
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    // TableViewのセルの数を指定
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchedResultList.count
    }
    
    // 1行毎のセルの要素を設定する(表示する中身の設定)
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // セルのインスタンス化　文字列を表示するCell
        let cell: SubSearchViewController! = tableView.dequeueReusableCell(withIdentifier: "searchviewtableviewcell", for: indexPath) as! SubSearchViewController
        cell.textLabel?.text = searchedResultList[indexPath.row][0] as? String
        if confirmRegistration(indexPathRow: indexPath.row) == true {
            cell.AddButton.setImage(UIImage(named: "deleteicon"), for: .normal)
            cell.AddButton.backgroundColor = UIColor(red: 150/255, green: 150/255, blue: 150/255, alpha: 1)
            cell.AddButton.layer.cornerRadius = 5.0
            // 未登録の場合の処理
        } else {
            cell.AddButton.setImage(UIImage(named: "addicon"), for: .normal)
            cell.AddButton.layer.cornerRadius = 5.0
        }
        
        // 選択されたセルindex格納をtagに格納
        cell.tag = indexPath.row
        return cell
    }
    
    // 検索機能
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        //キーボードを閉じる
        searchBar.endEditing(true)
    }
    
    // 入力中検索機能
    // テキスト変更時の呼び出しメソッド
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        var sortedValue: Array<Array<Any>> = []
        // 検索結果配列初期化
        searchedResultList.removeAll()
        
        if(searchBar.text == "") {
            // 検索文字列が空の場合は全件取得
            searchedResultList = NSArray(contentsOfFile: plistFilePath!) as! Array<Array<Any>>
        } else {
            // 参照用に全件取得
            searchedResultList = NSArray(contentsOfFile: plistFilePath!) as! Array<Array<Any>>
            // 検索文字列を含むデータを抽出
            for buffer in searchedResultList {
                if ((buffer[0]) as AnyObject).contains(searchBar.text!) {
                    print(buffer[0])
                    sortedValue.append(buffer)
                    print(sortedValue)
                }
            }
            // 検索文字列を含むデータを検索結果配列に追加
            searchedResultList.removeAll()
            searchedResultList = sortedValue
        }
        // View更新
        searchedResultsTableView.reloadData()
    }
    
    // セルをタップしたら遷移する
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        // 遷移元のViewController名
//        GlobalVariableManager.shared.callerViewName = "SearchViewController"
        // 選択した曲番号(配列のインデックス)を格納
        GlobalVariableManager.shared.tuneIndex = indexPath.row
        // セグエの名前を指定して画面遷移を発動
        performSegue(withIdentifier: "segue1", sender: nil)
    }
    
    // 既にMyPlayListに登録されているか確認する処理
    // 既に登録されていた場合はtrueを返す
    func confirmRegistration(indexPathRow: Int) -> Bool {
        var returnValue: Bool = false
        for buffer in GlobalVariableManager.shared.playList {
            if (searchedResultList[indexPathRow][0] as! String == buffer[0]) {
                returnValue = true
            }
        }
        return returnValue
    }
}
