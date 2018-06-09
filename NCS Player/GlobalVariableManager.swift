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
    
    // シングルトンの唯一性を保証するためprivateにする
    private override init() {
    }
}
