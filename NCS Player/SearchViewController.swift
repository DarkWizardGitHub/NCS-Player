//
//  SearchViewController.swift
//  NCS Player
//
//  Created by Dark on 2018/06/03.
//  Copyright © 2018年 Dark. All rights reserved.
//

import UIKit
import AVFoundation

class SearchViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    
    // ユーザーデフォルトインスタンス(参照)
    // let userDefaults = UserDefaults.standard
    
    // CoreData操作クラスインスタンス
    let coreDataManager: CoreDataManager<String> = CoreDataManager<String>(setEntityName: GlobalVariableManager.shared.coreDataEntityName, attributeNames: GlobalVariableManager.shared.coreDataAttributes)
    
    // 検索結果用配列(2次元配列)
    var searchedResultList: Array<Array<Any>> = []
    
//    var myPlayList: Array<Array<String>> = []

    // Outlet接続
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var searchedResultsTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.searchedResultsTableView.delegate = self
        self.searchedResultsTableView.dataSource = self
        // デリゲート先を自分に設定
        self.searchBar.delegate = self
        // 何も入力されていなくてもReturnキーを押せるように設定
        self.searchBar.enablesReturnKeyAutomatically = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let plistFilePath = Bundle.main.path(forResource: "Tunes", ofType:"plist")
        searchedResultList = NSArray(contentsOfFile: plistFilePath!) as! Array<Array<Any>>
        GlobalVariableManager.shared.myPlayList = (coreDataManager.readAll() as! Array<Array<String>>)
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
        cell.textLabel?.text = searchedResultList[indexPath.row][0] as! String
        if confirmRegistration(indexPathRow: indexPath.row) == true {
            cell.AddButton.setImage(UIImage(named: "deleteicon"), for: UIControlState())
            cell.AddButton.backgroundColor = UIColor(red: 100/255, green: 100/255, blue: 100/255, alpha: 1)
            cell.AddButton.layer.cornerRadius = 5.0
            // 未登録の場合の処理
        } else {
            cell.AddButton.setImage(UIImage(named: "addicon"), for: UIControlState())
            cell.AddButton.backgroundColor = UIColor(red: 32/255, green: 32/255, blue: 32/255, alpha: 1)
            cell.AddButton.layer.cornerRadius = 5.0
        }
        
//        検証１：選択されたセルのindex格納候補
        cell.tag = indexPath.row
//        print("親\(cell.tag)")
        return cell
    }
    
    // 既にMyPlayListに登録されているか確認する処理
    // 既に登録されていた場合はtrueを返す
    func confirmRegistration(indexPathRow: Int) -> Bool {
        var returnValue: Bool = false
        for buffer in GlobalVariableManager.shared.myPlayList {
            if (searchedResultList[indexPathRow][0] as! String == buffer[0]) {
                returnValue = true
            }
        }
        return returnValue
    }
}
