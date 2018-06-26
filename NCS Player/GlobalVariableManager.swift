//
//  GlobalVariableManager.swift
//  NCS Player
//
//  Created by Dark on 2018/06/09.
//  Copyright © 2018年 Dark. All rights reserved.
//

import Foundation

// プロジェクト内のグローバル変数管理用シングルトン
class GlobalVariableManager: NSObject {
    
    // シングルトン
    // シングルトンパターンはインスタンスが1個しか生成されないことを保証したい時に使用
    static let shared = GlobalVariableManager()
    
    var tuneIndex: Int!
    var playingTuneIndex: Int!
    var coreDataAttributes: [String]
    let coreDataEntityName: String

    
    
    struct tuneInformation {
        var tuneName: String
        var artistName: String
        var tunePath: String?
    }
 
    var tune0 = tuneInformation(tuneName: "Cloud 9", artistName: "Itro & Tobu", tunePath: Bundle.main.path(forResource: "Itro & Tobu-Cloud 9", ofType:"mp3")!)
    var tune1 = tuneInformation(tuneName: "Sthlm Sunset", artistName: "Ehrling", tunePath: Bundle.main.path(forResource: "Ehrling-Sthlm Sunset", ofType:"mp3")!)
    var tune2 = tuneInformation(tuneName: "Sunburst", artistName: "Tobu & Itro", tunePath: Bundle.main.path(forResource: "Tobu & Itro-Sunburst", ofType:"mp3")!)
    var tune3 = tuneInformation(tuneName: "Candyland", artistName: "Tobu", tunePath: Bundle.main.path(forResource: "Tobu-Candyland", ofType:"mp3")!)
    var tune4 = tuneInformation(tuneName: "Dance With Me", artistName: "Ehrling", tunePath: Bundle.main.path(forResource: "Ehrling-Dance With Me", ofType:"mp3")!)
    
    // 再生する audio ファイルのパスを取得
    lazy var playList = [tune0, tune1, tune2, tune3, tune4]
    
    
    
    
    // シングルトンの唯一性を保証するためprivateにする
    private override init() {
        coreDataAttributes = ["tune_name", "artist_name", "tune_path"]
        coreDataEntityName = "Tunes"
    }
}
