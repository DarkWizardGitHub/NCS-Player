//
//  AboutNCSViewController.swift
//  NCS Player
//
//  Created by Dark on 2018/07/13.
//  Copyright © 2018年 Dark. All rights reserved.
//

import UIKit

class AboutNCSViewController: UIViewController {
    
    @IBOutlet weak var explanationTextView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // アプリのversionとbuild番号表示
        let version: String! = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
        let text = """
        Developer: Dark
        Version: \(version!)
        
        NCSの世界にようこそ！
        本アプリは世界中の人々にNCSをより身近なものに感じてもらえるよう作られました。
        数あるNCSの曲から自分だけのお気に入りプレイリストを作り、NCSを存分に楽しんで下さい！
        """
        explanationTextView.text = text
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
