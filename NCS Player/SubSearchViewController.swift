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

    // CoreData操作クラスインスタンス
    let coreDataManager: CoreDataManager<String> = CoreDataManager<String>(setEntityName: GlobalVariableManager.shared.coreDataEntityName, attributeNames: GlobalVariableManager.shared.coreDataAttributes)
    
    // データ操作クラスインスタンス
    let dataStorageManager = DataStorageManager()
    
    // 検索結果用配列(2次元配列)
    var searchedResultList: Array<Array<Any>> = []
    
    var i:Int = 0
    var timer:Timer!
    
    
    
    // Outlet接続
    @IBOutlet weak var AddButton: UIButton!
    
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
            // Documentsフォルダからデータ削除
            self.dataStorageManager.delete(targetFolderPath: NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0], fileNameWithExtension: (self.textLabel?.text)! + ".mp3")
            // CoreDataのデータ削除
            coreDataManager.delete(attribute: GlobalVariableManager.shared.coreDataAttributes[0], relationalOperator: "=", placeholder: "%@", targetValue: searchedResultList[self.tag][0] as! String)
            // myPlayList更新
            GlobalVariableManager.shared.playList = (coreDataManager.readAll() as! Array<Array<String>>)
            // ボタン画像/色変更
            AddButton.setImage(UIImage(named: "addicon"), for: UIControlState())
            // alphaの透過率の関係でRGBがそのまま適用できないので
            AddButton.backgroundColor = UIColor(red: 66/255, green: 66/255, blue: 66/255, alpha: 1)
            AddButton.layer.cornerRadius = 5.0
        } else {
            // 未登録の場合の処理
            // Documentsフォルダにデータ追加
            // GCD（Grand Central Dispatch）のDispatchGroupを作成し、非同期処理の実行前にenter()、実行後にleave()を呼ぶことで、複数の非同期処理の開始と完了を管理
            // 全ての処理で完了の合図としてleave()が呼ばれた後に、notify()メソッドで指定したクロージャが実行
            let dispatchGroup = DispatchGroup()
            let queue = DispatchQueue.global()
            
            // 非同期処理開始
            dispatchGroup.enter()
            
            // メインスレッドで実行
            DispatchQueue.main.async {
                self.AddButton.isEnabled = false
                self.AddButton.setImage(UIImage(named: "downloadprogressbar0"), for: UIControlState())
                self.timer = Timer.scheduledTimer(withTimeInterval: 0.75, repeats: true, block: { (timer) in
                    self.AddButton.setImage(UIImage(named: "downloadprogressbar\(self.i)"), for: .disabled)
                    if self.i < 4 {
                        self.i += 1
                    } else {
                        self.i = 0
                    }
                })
            }
            
            // サブスレッドで実行
            queue.async {
                self.dataStorageManager.download(url: NSURL(string: "http://darkwizard.xsrv.jp/NCSPlayerTunes/" + (self.textLabel?.text?.replacingOccurrences(of: " ", with: "%20"))! + ".mp3")!, destinationFolderPath: NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0], fileNameWithExtension: (self.textLabel?.text)! + ".mp3")
                // 非同期処理終了
                dispatchGroup.leave()
            }
            
            // leave()が呼ばれた後の処理
            dispatchGroup.notify(queue: queue, execute: {
                // メインスレッドで実行
                DispatchQueue.main.async {
                    // CoreDataにデータ追加
                    self.coreDataManager.create(values: self.searchedResultList[self.tag] as! [String])
                    // myPlayList更新
                    GlobalVariableManager.shared.playList = (self.coreDataManager.readAll() as! Array<Array<String>>)
                    // タイマー破棄
                    self.timer.invalidate()
                    self.i = 0
                    self.AddButton.setImage(UIImage(named: "deleteicon"), for: UIControlState())
                    self.AddButton.backgroundColor = UIColor(red: 150/255, green: 150/255, blue: 150/255, alpha: 1)
                    self.AddButton.layer.cornerRadius = 5.0
                    self.AddButton.isEnabled = true
                }
            })
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
