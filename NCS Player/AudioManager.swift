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
    var finishedFlag: Bool = false
    
    // シングルトンの唯一性を保証するためprivateにする
    private override init() {
        audioVolume = 0.5
    }
    
    // メモリ上にデータを読み込み再生可能な状態にする
    func load(path: String) {
        let url = URL(fileURLWithPath: path)
        do {
            // auido を再生するプレイヤーを作成
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
        audioBuffer?.play()
    }
    
    func pause() {
        audioBuffer?.pause()
    }
    
//    func forward() {
//
//    }
//
//    func backward() {
//
//    }

    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        print("dfp")
        finishedFlag = true
//        struct tuneInformation {
//            var tuneName: String
//            var artistName: String
//            var tunePath: String
//        }
//
//        var tune0 = tuneInformation(tuneName: "Cloud 9", artistName: "Itro & Tobu", tunePath: Bundle.main.path(forResource: "Itro & Tobu-Cloud 9", ofType:"mp3")!)
//        var tune1 = tuneInformation(tuneName: "Sthlm Sunset", artistName: "Ehrling", tunePath: Bundle.main.path(forResource: "Ehrling-Sthlm Sunset", ofType:"mp3")!)
//        var tune2 = tuneInformation(tuneName: "Sunburst", artistName: "Tobu & Itro", tunePath: Bundle.main.path(forResource: "Tobu & Itro-Sunburst", ofType:"mp3")!)
//        var tune3 = tuneInformation(tuneName: "Candyland", artistName: "Tobu", tunePath: Bundle.main.path(forResource: "Tobu-Candyland", ofType:"mp3")!)
//        var tune4 = tuneInformation(tuneName: "Dance With Me", artistName: "Ehrling", tunePath: Bundle.main.path(forResource: "Ehrling-Dance With Me", ofType:"mp3")!)
//
//        // 再生する audio ファイルのパスを取得
//        var tunes = [tune0, tune1, tune2, tune3, tune4]
//
//            GlobalVariableManager.shared.tuneIndex = GlobalVariableManager.shared.tuneIndex! + 1
//            self.load(path: tunes[GlobalVariableManager.shared.tuneIndex!].tunePath)
//            AudioManager.shared.play(volumeValue: AudioManager.shared.audioVolume)
//            // 再生アイコン切り替え
////            controlButton.setImage(UIImage(named: "pauseicon"), for: UIControlState())
    }
}
