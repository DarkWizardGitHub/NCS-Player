//
//  ViewController.swift
//  NCS Player
//
//  Created by Dark on 2018/05/29.
//  Copyright © 2018年 Dark. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController, AVAudioPlayerDelegate, UINavigationControllerDelegate {

//    var audioPlayer: AVAudioPlayer!
    var playTimer: Timer!
//    var tuneIndex: Int? = nil
//    var playingTuneIndex: Int?
    
    struct tuneInformation {
        var tuneName: String
        var artistName: String
        var tunePath: String
    }
    
    var tune0 = tuneInformation(tuneName: "Cloud 9", artistName: "Itro & Tobu", tunePath: Bundle.main.path(forResource: "Itro & Tobu-Cloud 9", ofType:"mp3")!)
    var tune1 = tuneInformation(tuneName: "Sthlm Sunset", artistName: "Ehrling", tunePath: Bundle.main.path(forResource: "Ehrling-Sthlm Sunset", ofType:"mp3")!)
    var tune2 = tuneInformation(tuneName: "Sunburst", artistName: "Tobu & Itro", tunePath: Bundle.main.path(forResource: "Tobu & Itro-Sunburst", ofType:"mp3")!)
    var tune3 = tuneInformation(tuneName: "Candyland", artistName: "Tobu", tunePath: Bundle.main.path(forResource: "Tobu-Candyland", ofType:"mp3")!)
    var tune4 = tuneInformation(tuneName: "Dance With Me", artistName: "Ehrling", tunePath: Bundle.main.path(forResource: "Ehrling-Dance With Me", ofType:"mp3")!)
    
    // 再生する audio ファイルのパスを取得
    lazy var tunes = [tune0, tune1, tune2, tune3, tune4]
//    var Tunes = [Bundle.main.path(forResource: "Ehrling-Sthlm Sunset", ofType:"mp3")!, Bundle.main.path(forResource: "Itro & Tobu-Cloud 9", ofType:"mp3")!]

    // アウトレット接続
    @IBOutlet weak var playbackPositionSlider: UISlider!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var artistLabel: UILabel!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var controlButton: UIButton!
    @IBOutlet weak var volumeSlider: UISlider!
    @IBOutlet weak var leftPlaybackPositionLabel: UILabel!
    @IBOutlet weak var rightPlaybackPositionLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        print("proceeded vdl")
        // playbackPositionSliderの設定
        // スライダー非操作時の画像
        self.playbackPositionSlider.setThumbImage(UIImage(named: "playbackpositioncursor"), for: .normal)
        // スライダー操作時の画像
        self.playbackPositionSlider.setThumbImage(UIImage(named: "playbackpositioncursor"), for: .highlighted)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print(GlobalVariableManager.shared.tuneIndex)
        print(GlobalVariableManager.shared.playingTuneIndex)
        if GlobalVariableManager.shared.tuneIndex != GlobalVariableManager.shared.playingTuneIndex {
            print("proceeded")
            self.prepareTune()
        } else {
            AudioManager.shared.play(volumeValue: AudioManager.shared.audioVolume)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // Timerで1秒毎にプレイヤーのcurrentTimeとスライダーのvalueを同期、leftPlaybackPositionLabelのtextをプレイヤーのcurrentTimeと同期
        self.playTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true, block: {(action) in
            self.changePlaybackPositionSlider()
            self.changeLeftPlaybackPositionLabel(value: (AudioManager.shared.audioBuffer?.currentTime)!)
        })
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        // 画面遷移時にタイマー破棄
        self.playTimer = nil
        GlobalVariableManager.shared.playingTuneIndex = GlobalVariableManager.shared.tuneIndex
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func prepareTune() {
        AudioManager.shared.load(path: tunes[GlobalVariableManager.shared.tuneIndex!].tunePath)
        // 曲名とアーティスト名取得
        self.titleLabel.text = tunes[GlobalVariableManager.shared.tuneIndex!].tuneName
        self.artistLabel.text = tunes[GlobalVariableManager.shared.tuneIndex!].artistName
        self.volumeSlider.value = AudioManager.shared.audioVolume
        // スライダーの最大値と音楽ファイルの長さを同期
        // スライダーの値はFloat型になるのでFloat型にキャスト変換
        // duration Type:TimeInterval /The total duration, in seconds, of the sound associated with the audio player
        self.playbackPositionSlider.maximumValue = Float((AudioManager.shared.audioBuffer?.duration)!)
        self.rightPlaybackPositionLabel.text = convertTimeIntervalToString(value: (AudioManager.shared.audioBuffer?.duration)!)
    }
    
    // backボタンを押すと以下の２パターンの処理を行う
    // 再生中→音楽の再生位置はリセットされ1個前の曲の頭から演奏が始まる
    // 一時停止中→音楽の再生位置はリセットされ1個前の曲の頭で一時停止する
    // プレイリストの先頭の場合のみ再度その曲を選択する
    @IBAction func backButton(_ sender: UIButton) {
        if (AudioManager.shared.audioBuffer?.isPlaying)! {
            if GlobalVariableManager.shared.tuneIndex! == 0 {
                self.prepareTune()
                AudioManager.shared.play(volumeValue: AudioManager.shared.audioVolume)
                // 再生アイコン切り替え
                self.controlButton.setImage(UIImage(named: "pauseicon"), for: UIControlState())
            } else {
                GlobalVariableManager.shared.tuneIndex = GlobalVariableManager.shared.tuneIndex! - 1
                self.prepareTune()
                AudioManager.shared.play(volumeValue: AudioManager.shared.audioVolume)
                // 再生アイコン切り替え
                self.controlButton.setImage(UIImage(named: "pauseicon"), for: UIControlState())
            }
        } else {
            if GlobalVariableManager.shared.tuneIndex! == 0 {
                self.prepareTune()
                // 一時停止アイコン切り替え
                controlButton.setImage(UIImage(named: "playicon"), for: UIControlState())
            } else {
                GlobalVariableManager.shared.tuneIndex = GlobalVariableManager.shared.tuneIndex! - 1
                self.prepareTune()
                // 一時停止アイコン切り替え
                controlButton.setImage(UIImage(named: "playicon"), for: UIControlState())
            }
        }
    }
    
    @IBAction func controlButton(_ sender: UIButton) {
        if (AudioManager.shared.audioBuffer?.isPlaying)! {
            // 一時停止
            AudioManager.shared.pause()
            // 再生アイコン切り替え
            controlButton.setImage(UIImage(named: "playicon"), for: UIControlState())
        } else {
            // 再生
            AudioManager.shared.play(volumeValue: AudioManager.shared.audioVolume)
            // 一時停止アイコン切り替え
            controlButton.setImage(UIImage(named: "pauseicon"), for: UIControlState())
        }
    }
    
    // nextボタンを押すと以下の２パターンの処理を行う
    // 再生中→音楽の再生位置はリセットされ1個後の曲の頭から演奏が始まる
    // 一時停止中→音楽の再生位置はリセットされ1個後の曲の頭で一時停止する
    // プレイリストの末尾の場合のみ再度その曲を選択する
    @IBAction func nextButton(_ sender: UIButton) {
        if (AudioManager.shared.audioBuffer?.isPlaying)! {
            if GlobalVariableManager.shared.tuneIndex! == tunes.count - 1 {
                self.prepareTune()
                AudioManager.shared.play(volumeValue: AudioManager.shared.audioVolume)
                // 再生アイコン切り替え
                controlButton.setImage(UIImage(named: "pauseicon"), for: UIControlState())
            } else {
                GlobalVariableManager.shared.tuneIndex = GlobalVariableManager.shared.tuneIndex! + 1
                self.prepareTune()
                AudioManager.shared.play(volumeValue: AudioManager.shared.audioVolume)
                // 再生アイコン切り替え
                controlButton.setImage(UIImage(named: "pauseicon"), for: UIControlState())
            }
        } else {
            if GlobalVariableManager.shared.tuneIndex! == tunes.count - 1 {
                self.prepareTune()
                // 一時停止アイコン切り替え
                controlButton.setImage(UIImage(named: "playicon"), for: UIControlState())
            } else {
                GlobalVariableManager.shared.tuneIndex = GlobalVariableManager.shared.tuneIndex! + 1
                self.prepareTune()
                // 一時停止アイコン切り替え
                controlButton.setImage(UIImage(named: "playicon"), for: UIControlState())
            }
        }
    }
    
    @IBAction func playbackPositionSlider(_ sender: UISlider) {
        AudioManager.shared.audioBuffer?.currentTime = TimeInterval(playbackPositionSlider.value)
    }
    
    // 手動音量調整の為スライダーのvalueをプレイヤーのvolumeに代入
    @IBAction func volumeSlider(_ sender: UISlider) {
//        audioPlayer.volume = volumeSlider.value
        // ユーザー設定のvolumeを保持
        AudioManager.shared.audioVolume = volumeSlider.value
        AudioManager.shared.audioBuffer?.volume = AudioManager.shared.audioVolume
    }
    
    // playbackPositionSliderのvalueをリアルタイムに書き換える関数
    func changePlaybackPositionSlider() {
        playbackPositionSlider.value = Float((AudioManager.shared.audioBuffer?.currentTime)!)
    }
    
    // leftPlaybackPositionLabelのtextをリアルタイムにプレイヤーのcurrentTimeに書き換える関数
    func changeLeftPlaybackPositionLabel(value:TimeInterval) {
        let formatter = DateFormatter()
        formatter.dateFormat = "mm:ss"
        let returnvalue = formatter.string(from: Date(timeIntervalSinceReferenceDate: value))
        self.leftPlaybackPositionLabel.text = returnvalue
    }
    
    // TimeInterval型をString型に変換する関数
    func convertTimeIntervalToString(value:TimeInterval) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "mm:ss"
        let returnvalue = formatter.string(from: Date(timeIntervalSinceReferenceDate: value))
        return returnvalue
    }
}

