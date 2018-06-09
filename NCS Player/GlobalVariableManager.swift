//
//  GlobalVariableManager.swift
//  NCS Player
//
//  Created by Dark on 2018/06/09.
//  Copyright © 2018年 Dark. All rights reserved.
//

import Foundation

class GlobalVariableManager: NSObject {
    static let shared = GlobalVariableManager()
    
    var tuneIndex: Int!
    var playingTuneIndex: Int!
    
    // シングルトンの唯一性を保証するためprivateにする
    private override init() {
    }
}
