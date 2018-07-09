//
//  DataStorageManager.swift
//  NCS Player
//
//  Created by Dark on 2018/07/06.
//  Copyright © 2018年 Dark. All rights reserved.
//

import Foundation

class DataStorageManager: NSObject {
    
    // Documentsフォルダパス取得
    // どちらでも可
    // let documentsFolderPath: String = NSHomeDirectory() + "/Documents"
    // let documentsFolderPath: String = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0]
    
    // URLをNSURLに変換して扱う場合、string:を使用
    // let musicUrl = NSURL(string: "http://www.hurtrecord.com/se/operation/b1-007_computer_01.mp3")
    // ローカルファイルパスをNSURLに変換して扱う場合、fileURLWithPath:を使用
    // let musicUrl = NSURL(fileURLWithPath: "/Users/Dark/Desktop/THBD-Good For You.mp3")
    
    func download(url: NSURL, destinationFolderPath: String, fileNameWithExtension: String) {

            let data = NSData(contentsOf: url as! URL)
            data?.write(toFile: "\(destinationFolderPath)/\(fileNameWithExtension)", atomically: true)
    }
    
    func delete(targetFolderPath: String, fileNameWithExtension: String) {
        
        do {
            try FileManager.default.removeItem(atPath: "\(targetFolderPath)/\(fileNameWithExtension)")
        } catch {
            //エラー処理
            print("error")
        }
    }
}
