//
//  SearchViewController.swift
//  NCS Player
//
//  Created by Dark on 2018/06/03.
//  Copyright © 2018年 Dark. All rights reserved.
//

import UIKit
import AVFoundation

class SearchViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    // ユーザーデフォルトインスタンス(参照)
    // let userDefaults = UserDefaults.standard
    
    // CoreData操作クラスインスタンス
    let coreDataManager: CoreDataManager<String> = CoreDataManager<String>(setEntityName: GlobalVariableManager.shared.coreDataEntityName, attributeNames: GlobalVariableManager.shared.coreDataAttributes)
    
    // 検索結果用配列(1次元配列)
//    var searchedResultsList: Array<String> = []
    var searchedResultsList: Array<String>  = ["a", "b", "c"]

    // Outlet接続
    @IBOutlet weak var searchedResultsTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.searchedResultsTableView.delegate = self
        self.searchedResultsTableView.dataSource = self
        
        let nib = UINib(nibName: "SubSearchViewController", bundle: nil)
        searchedResultsTableView.register(nib, forCellReuseIdentifier: "searchviewtableviewcell")
//        AddButton.layer.borderColor = UIColor(red: 32/255, green: 32/255, blue: 32/255, alpha: 1) as! CGColor
//        AddButton.layer.borderWidth = 1.0
//        AddButton.layer.cornerRadius = 10.0 //丸みを数値で変更できます
        
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
        return searchedResultsList.count
    }
    
    // 1行毎のセルの要素を設定する(表示する中身の設定)
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // セルのインスタンス化　文字列を表示するCell
        let cell: UITableViewCell! = tableView.dequeueReusableCell(withIdentifier: "searchviewtableviewcell", for: indexPath)
        cell.textLabel?.text = searchedResultsList[indexPath.row]
        cell.add
        return cell
    }
}
