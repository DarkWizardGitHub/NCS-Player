//
//  AudioManager.swift
//  NCS Player
//
//  Created by Dark on 2018/06/06.
//  Copyright © 2018年 Dark. All rights reserved.
//

import UIKit
import AVFoundation

class AudioManager: NSObject, AVAudioPlayerDelegate {
    
    // シングルトン
    // シングルトンパターンはインスタンスが1個しか生成されないことを保証したい時に使用
    static let shared = AudioManager()
    
    var audioBuffer: AVAudioPlayer? = nil
    var audioPlayer: AVAudioPlayer!
    var audioVolume: Float!
    var audioPlayMode: String = "Normal"
    var loopTimes: Int = 0
    var finishedFlag: Bool = false
    
    // シングルトンの唯一性を保証するためprivateにする
    private override init() {
        audioVolume = 0.5
    }
    
    // メモリ上にデータを読み込み再生可能な状態にする
    func load(fileName: String, fileExtension: String) {
        let url = URL(fileURLWithPath: Bundle.main.path(forResource: fileName, ofType: fileExtension)!)
        do {
            // audio を再生するプレイヤーを作成
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioBuffer = audioPlayer
            audioBuffer?.prepareToPlay()
            audioPlayer = nil
        } catch {
            print("File doesn't exist.")
        }
    }
    
    func play(volumeValue: Float) {
        audioBuffer?.volume = volumeValue
        audioBuffer?.delegate = self
        audioBuffer?.numberOfLoops = loopTimes
        audioBuffer?.play()
    }
    
    func pause() {
        audioBuffer?.pause()
    }

    // オーディオファイル再生終了検知
    // 再生が終わるとデリゲートのこのメソッドがコールバックされる
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        // 再生終了後の処理をViewController側で行うため、グローバル変数に再生終了用の変数を作成し状態を保持する
        finishedFlag = true
    }
}
