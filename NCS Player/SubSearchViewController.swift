//
//  SubSearchViewController.swift
//  NCS Player
//
//  Created by Dark on 2018/06/03.
//  Copyright © 2018年 Dark. All rights reserved.
//

import UIKit

//SearchViewController内のセルに設置したButtonの処理用サブクラス
class SubSearchViewController: UITableViewCell {

    @IBOutlet weak var AddButton: UIButton!
    
    // CoreData操作クラスインスタンス
    let coreDataManager: CoreDataManager<String> = CoreDataManager<String>(setEntityName: GlobalVariableManager.shared.coreDataEntityName, attributeNames: GlobalVariableManager.shared.coreDataAttributes)
    
    // 検索結果用配列(2次元配列)
    var searchedResultList: Array<Array<Any>> = []

    // nibファイルがオープンされた際に１度だけ呼び出されるメソッド
    override func awakeFromNib() {

        let plistFilePath = Bundle.main.path(forResource: "Tunes", ofType:"plist")
        searchedResultList = NSArray(contentsOfFile: plistFilePath!) as! Array<Array<Any>>
        GlobalVariableManager.shared.playList = (coreDataManager.readAll() as! Array<Array<String>>)
    }

    // CoreData(MyPlayList)のデータ追加/削除処理
    @IBAction func pushAddButton(_ sender: UIButton) {
        if confirmRegistration(indexPathRow: self.tag) == true {
            // 登録済みの場合の処理
            AddButton.setImage(UIImage(named: "addicon"), for: UIControlState())
            AddButton.backgroundColor = UIColor(red: 32/255, green: 32/255, blue: 32/255, alpha: 1)
            AddButton.layer.cornerRadius = 5.0
            print("Delete")
            // CoreDataのデータ削除
            coreDataManager.delete(attribute: GlobalVariableManager.shared.coreDataAttributes[0], relationalOperator: "=", placeholder: "%@", targetValue: searchedResultList[self.tag][0] as! String)
            // myPlayList更新
            GlobalVariableManager.shared.playList = (coreDataManager.readAll() as! Array<Array<String>>)
        } else {
            // 未登録の場合の処理
            AddButton.setImage(UIImage(named: "deleteicon"), for: UIControlState())
            AddButton.backgroundColor = UIColor(red: 150/255, green: 150/255, blue: 150/255, alpha: 1)
            AddButton.layer.cornerRadius = 5.0
            print("Add")
            // CoreDataにデータ追加
            coreDataManager.create(values: searchedResultList[self.tag] as! [String])
            // myPlayList更新
            GlobalVariableManager.shared.playList = (coreDataManager.readAll() as! Array<Array<String>>)
        }
        // textラベルで曲名も取れる
        // print(self.textLabel?.text)
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
