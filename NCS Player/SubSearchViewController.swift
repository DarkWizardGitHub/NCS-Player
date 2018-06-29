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
    
    // CoreData(MyPlayList)へデータ追加処理
    @IBAction func pushAddButton(_ sender: UIButton) {
        print("Add")
    }
    
    
    //        AddButton.layer.borderColor = UIColor(red: 32/255, green: 32/255, blue: 32/255, alpha: 1) as! CGColor
//        AddButton.layer.borderWidth = 1.0
//        AddButton.layer.cornerRadius = 10.0 //丸みを数値で変更できます

    
}
