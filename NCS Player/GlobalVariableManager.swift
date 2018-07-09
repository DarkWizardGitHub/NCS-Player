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
    
    // MyPlayList用配列(2次元配列)
    // [[String]] = [] でも同義
    var playList: Array<Array<String>> = []
    
    var callerViewName: String!
    var tuneIndex: Int!
    var playingTuneIndex: Int!
    var coreDataAttributes: [String]
    let coreDataEntityName: String
    
    // シングルトンの唯一性を保証するためprivateにする
    private override init() {
        coreDataAttributes = ["tune_name", "artist_name", "file_extension", "youtube_url"]
        coreDataEntityName = "Tunes"
    }
}
