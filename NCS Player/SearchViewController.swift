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
    let coreDataManager: CoreDataManager<Any> = CoreDataManager<Any>(setEntityName: GlobalVariableManager.shared.coreDataEntityName, attributeNames: GlobalVariableManager.shared.coreDataAttributes)
    
    // 検索結果用配列(2次元配列)
    var searchedResultList: Array<Array<Any>> = []
    
    var myPlayList: Array<Array<Any>> = []

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
        myPlayList = (coreDataManager.readAll() as! Array<Array<Any>>).filter{ $0[4] as! Bool == true }
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
            cell.AddButton.backgroundColor = UIColor(red: 32/255, green: 32/255, blue: 32/255, alpha: 1)
            cell.AddButton.layer.borderWidth = 1.0
            cell.AddButton.layer.cornerRadius = 5.0
        } else {
            cell.AddButton.isHidden = true
        }
//        以下の処理だとうまくいかない、下の関数を作成したがなんか美しくない、相談する
//        for buffer in myPlayList {
//            if (searchedResultList[indexPath.row][0] as! String != buffer[0] as! String) {
//                cell.AddButton.backgroundColor = UIColor(red: 32/255, green: 32/255, blue: 32/255, alpha: 1)
//                cell.AddButton.layer.borderWidth = 1.0
//                cell.AddButton.layer.cornerRadius = 5.0
//                print("break\(indexPath.row)")
//                break
//            } else {
//                cell.AddButton.isHidden = true
//            }
//        }
        return cell
    }
    
    func confirmRegistration(indexPathRow: Int) -> Bool {
        var hoge: Bool = true
        for buffer in myPlayList {
            if (searchedResultList[indexPathRow][0] as! String == buffer[0] as! String) {
                hoge = false
            }
        }
        return hoge
    }
}
