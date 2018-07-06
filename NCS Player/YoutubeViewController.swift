//
//  YoutubeViewController.swift
//  NCS Player
//
//  Created by Dark on 2018/07/06.
//  Copyright © 2018年 Dark. All rights reserved.
//

import UIKit

class YoutubeViewController: UIViewController {
    
    // plistファイルパス
    let plistFilePath = Bundle.main.path(forResource: "Tunes", ofType:"plist")
    var tunesList: Array<Array<String>> = []
    
    @IBOutlet weak var youtubeWebView: UIWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // sorted{}内で第一引数$0と第二引数$1の先頭の要素(曲名)を比較しアルファベット順に並び替え
        tunesList = (NSArray(contentsOfFile: plistFilePath!) as! Array<Array<Any>>).sorted{ ($0[0] as! String) < ($1[0] as! String) } as! Array<Array<String>>
        
        var hoge: String = self.tunesList[GlobalVariableManager.shared.tuneIndex][4]
        let url: NSURL = NSURL(string: hoge)!
        let request: NSURLRequest = NSURLRequest(url: url as URL)
        youtubeWebView.loadRequest(request as URLRequest)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
