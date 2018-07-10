//
//  SubArtistInformationViewController.swift
//  NCS Player
//
//  Created by Dark on 2018/07/04.
//  Copyright © 2018年 Dark. All rights reserved.
//

import UIKit

//SearchViewController内のセルに設置したButtonの処理用サブクラス
class SubArtistInformationViewController: UITableViewCell {

    @IBOutlet weak var jumpToWebButton: UIButton!
    @IBOutlet weak var jumpToYoutubeButton: UIButton!
    
    // CoreData操作クラスインスタンス
    let coreDataManager: CoreDataManager<String> = CoreDataManager<String>(setEntityName: GlobalVariableManager.shared.coreDataEntityName, attributeNames: GlobalVariableManager.shared.coreDataAttributes)
    
    // 検索結果用配列(2次元配列)
    var artistList: Array<Array<Any>> = []
    
    // nibファイルがオープンされた際に１度だけ呼び出されるメソッド
    override func awakeFromNib() {
        
        let plistFilePath = Bundle.main.path(forResource: "Artists", ofType:"plist")
        artistList = NSArray(contentsOfFile: plistFilePath!) as! Array<Array<Any>>
    }
    
    // WEBへリンク
    @IBAction func pushJumpToWebButton(_ sender: Any) {
        // cellのtextlabelの文字列とartistList内のartist名を比較してartistのサイトURLを取得する
        let url = URL(string: artistList.filter{ $0[0] as! String == self.textLabel?.text as! String}.first![1] as! String)
        if UIApplication.shared.canOpenURL(url!) {
            UIApplication.shared.open(url!)
        }
    }
    
    // Youtubeへリンク
    @IBAction func pushJumpToYoutubeButton(_ sender: Any) {
    // cellのtextlabelの文字列とartistList内のartist名を比較してartistのサイトURLを取得する
        let url = URL(string: artistList.filter{ $0[0] as! String == self.textLabel?.text as! String}.first![2] as! String)
        if UIApplication.shared.canOpenURL(url!) {
            UIApplication.shared.open(url!)
        }
    }
}
