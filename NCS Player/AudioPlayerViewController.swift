//
//  ViewController.swift
//  NCS Player
//
//  Created by Dark on 2018/05/29.
//  Copyright © 2018年 Dark. All rights reserved.
//

import UIKit
import AVFoundation

class AudioPlayerViewController: UIViewController, AVAudioPlayerDelegate, UINavigationControllerDelegate {
    
    // UserDefaultsインスタンス(参照)
    // let userDefaults = UserDefaults.standard
    
    // CoreData操作クラスインスタンス
    let coreDataManager: CoreDataManager<Any> = CoreDataManager<Any>(setEntityName: GlobalVariableManager.shared.coreDataEntityName, attributeNames: GlobalVariableManager.shared.coreDataAttributes)
    
    // plistファイルパス
    let plistFilePath = Bundle.main.path(forResource: "Tunes", ofType:"plist")
    
    // タイマー関数用変数
    var playTimer: Timer!
    
    // PlayModeボタンが押された時点のCurrentTime記録用変数
    var changedPlayModeTime: TimeInterval!
    
    enum playMode: String {
        case isNormal = "Normal"
        case isRepeat = "Repeat"
        case isShuffle = "Shuffle"
    }

    // Outlet接続
    @IBOutlet weak var playModeButton: UIButton!
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
        
        // 画面左側にNavigationController用のPopGestureRecognizer感知領域(スワイプで戻る処理)がある為、その領域内にLongPressGestureRecognizer設置すると感知されない現象が発生(おそらくPopGestureRecognizerが優先されている)、対策としてPopGestureRecognizerを不能にする
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        // スライダー非操作時の画像
        self.playbackPositionSlider.setThumbImage(UIImage(named: "playbackpositioncursor"), for: .normal)
        // スライダー操作時の画像
        self.playbackPositionSlider.setThumbImage(UIImage(named: "playbackpositioncursor"), for: .highlighted)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // UserDefaultsからMyPlayListデータを取得
        // as! [[String]] = [] でも同義
        // 2次元配列の為ダウンキャストも2次元配列にする
        // myPlayList = userDefaults.object(forKey: "myPlayList") as! Array<Array<String>>
        
        // CoreDataからMyPlayListデータを取得
        switch GlobalVariableManager.shared.callerViewName {
            // as! [[String]] = [] でも同義
            // 2次元配列の為ダウンキャストも2次元配列にする
//            case "SearchViewController":
//                GlobalVariableManager.shared.playList = NSArray(contentsOfFile: plistFilePath!) as! Array<Array<String>>
            case "MyPlayListViewController":
                GlobalVariableManager.shared.playList = coreDataManager.readAll() as! Array<Array<String>>
            default:
                break
        }
        
        if GlobalVariableManager.shared.tuneIndex != GlobalVariableManager.shared.playingTuneIndex {
            self.prepareTune()
        } else {
            // 再生アイコン切り替え
            if (AudioManager.shared.audioBuffer?.isPlaying)! {
                self.controlButton.setImage(UIImage(named: "pauseicon"), for: UIControlState())
            } else {
                self.controlButton.setImage(UIImage(named: "playicon"), for: UIControlState())
            }
            // オーディオデータの読み込み以外はprepareTune()と同処理
            self.titleLabel.text = GlobalVariableManager.shared.playList[GlobalVariableManager.shared.tuneIndex!][0]
            self.artistLabel.text = GlobalVariableManager.shared.playList[GlobalVariableManager.shared.tuneIndex!][1]
            self.volumeSlider.value = AudioManager.shared.audioVolume
            self.playbackPositionSlider.maximumValue = Float((AudioManager.shared.audioBuffer?.duration)!)
            self.playbackPositionSlider.value = Float((AudioManager.shared.audioBuffer?.currentTime)!)
            self.synchronizeLeftPlaybackPositionLabel(value: (AudioManager.shared.audioBuffer?.currentTime)!)
            self.rightPlaybackPositionLabel.text = convertTimeIntervalToString(value: (AudioManager.shared.audioBuffer?.duration)!)
            switch AudioManager.shared.audioPlayMode {
            case "Normal":
                self.playModeButton.setImage(UIImage(named: "normalmodeicon128"), for: UIControlState())
            case "Repeat":
                self.playModeButton.setImage(UIImage(named: "repeatmodeicon128"), for: UIControlState())
            case "Shuffle":
                self.playModeButton.setImage(UIImage(named: "shufflemodeicon128"), for: UIControlState())
            default:
                break
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // Timerで1秒毎にプレイヤーのcurrentTimeとスライダーのvalueを同期、leftPlaybackPositionLabelのtextをプレイヤーのcurrentTimeと同期
        self.playTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true, block: {(action) in
            self.synchronizePlaybackPositionSlider()
            self.synchronizeLeftPlaybackPositionLabel(value: (AudioManager.shared.audioBuffer?.currentTime)!)
            self.playNextTune()
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
    
    // 通常再生、リピート再生、シャッフル再生を切り替える
    @IBAction func changePlayModeButton(_ sender: UIButton) {
        switch AudioManager.shared.audioPlayMode {
            case "Normal":
                AudioManager.shared.loopTimes = 1
                AudioManager.shared.audioPlayMode = playMode.isRepeat.rawValue
                self.playModeButton.setImage(UIImage(named: "repeatmodeicon128"), for: UIControlState())
                self.reloadTune()
            case "Repeat":
                AudioManager.shared.loopTimes = 0
                AudioManager.shared.audioPlayMode = playMode.isShuffle.rawValue
                self.playModeButton.setImage(UIImage(named: "shufflemodeicon128"), for: UIControlState())
                self.reloadTune()
            case "Shuffle":
                AudioManager.shared.loopTimes = 0 // シャッフル用のnumberOfLoopsに割り当てられた整数がないので0とする
                AudioManager.shared.audioPlayMode = playMode.isNormal.rawValue
                self.playModeButton.setImage(UIImage(named: "normalmodeicon128"), for: UIControlState())
                self.reloadTune()
            default:
                break
        }
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
                self.controlButton.setImage(UIImage(named: "playicon"), for: UIControlState())
            } else {
                GlobalVariableManager.shared.tuneIndex = GlobalVariableManager.shared.tuneIndex! - 1
                self.prepareTune()
                // 一時停止アイコン切り替え
                self.controlButton.setImage(UIImage(named: "playicon"), for: UIControlState())
            }
        }
    }
    
    // 再生、一時停止切り替え(停止は不要なので未実装)
    @IBAction func controlButton(_ sender: UIButton) {
        if (AudioManager.shared.audioBuffer?.isPlaying)! {
            // 一時停止
            AudioManager.shared.pause()
            // 再生アイコン切り替え
            self.controlButton.setImage(UIImage(named: "playicon"), for: UIControlState())
        } else {
            // 再生
            AudioManager.shared.play(volumeValue: AudioManager.shared.audioVolume)
            // 一時停止アイコン切り替え
            self.controlButton.setImage(UIImage(named: "pauseicon"), for: UIControlState())
        }
    }
    
    // nextボタンを押すと以下の２パターンの処理を行う
    // 再生中→音楽の再生位置はリセットされ1個後の曲の頭から演奏が始まる
    // 一時停止中→音楽の再生位置はリセットされ1個後の曲の頭で一時停止する
    // プレイリストの末尾の場合のみ再度その曲を選択する
    @IBAction func nextButton(_ sender: UIButton) {
        if (AudioManager.shared.audioBuffer?.isPlaying)! {
            if GlobalVariableManager.shared.tuneIndex! == GlobalVariableManager.shared.playList.count - 1 {
                switch AudioManager.shared.audioPlayMode {
                    case "Repeat":
                        self.prepareTune()
                        AudioManager.shared.play(volumeValue: AudioManager.shared.audioVolume)
                        // 再生アイコン切り替え
                        self.controlButton.setImage(UIImage(named: "pauseicon"), for: UIControlState())
                    case "Shuffle":
                        GlobalVariableManager.shared.tuneIndex = Int(arc4random_uniform(UInt32(GlobalVariableManager.shared.playList.count)))
                        self.prepareTune()
                        AudioManager.shared.play(volumeValue: AudioManager.shared.audioVolume)
                        // 再生アイコン切り替え
                        self.controlButton.setImage(UIImage(named: "pauseicon"), for: UIControlState())
                    default:
                        self.prepareTune()
                        AudioManager.shared.play(volumeValue: AudioManager.shared.audioVolume)
                        // 再生アイコン切り替え
                        self.controlButton.setImage(UIImage(named: "pauseicon"), for: UIControlState())
                }
            } else {
                switch AudioManager.shared.audioPlayMode {
                    case "Repeat":
                        self.prepareTune()
                        AudioManager.shared.play(volumeValue: AudioManager.shared.audioVolume)
                        // 再生アイコン切り替え
                        self.controlButton.setImage(UIImage(named: "pauseicon"), for: UIControlState())
                    case "Shuffle":
                        GlobalVariableManager.shared.tuneIndex = Int(arc4random_uniform(UInt32(GlobalVariableManager.shared.playList.count)))
                        self.prepareTune()
                        AudioManager.shared.play(volumeValue: AudioManager.shared.audioVolume)
                        // 再生アイコン切り替え
                        self.controlButton.setImage(UIImage(named: "pauseicon"), for: UIControlState())
                    default:
                        GlobalVariableManager.shared.tuneIndex = GlobalVariableManager.shared.tuneIndex! + 1
                        self.prepareTune()
                        AudioManager.shared.play(volumeValue: AudioManager.shared.audioVolume)
                        // 再生アイコン切り替え
                        self.controlButton.setImage(UIImage(named: "pauseicon"), for: UIControlState())
                }
            }
        } else {
            if GlobalVariableManager.shared.tuneIndex! == GlobalVariableManager.shared.playList.count - 1 {
                switch AudioManager.shared.audioPlayMode {
                    case "Repeat":
                        self.prepareTune()
                        // 再生アイコン切り替え
                        self.controlButton.setImage(UIImage(named: "playicon"), for: UIControlState())
                    case "Shuffle":
                        GlobalVariableManager.shared.tuneIndex = Int(arc4random_uniform(UInt32(GlobalVariableManager.shared.playList.count)))
                        self.prepareTune()
                        // 再生アイコン切り替え
                        self.controlButton.setImage(UIImage(named: "playicon"), for: UIControlState())
                    default:
                        self.prepareTune()
                        // 再生アイコン切り替え
                        self.controlButton.setImage(UIImage(named: "playicon"), for: UIControlState())
                }
            } else {
                switch AudioManager.shared.audioPlayMode {
                    case "Repeat":
                        self.prepareTune()
                        // 再生アイコン切り替え
                        self.controlButton.setImage(UIImage(named: "playicon"), for: UIControlState())
                    case "Shuffle":
                        GlobalVariableManager.shared.tuneIndex = Int(arc4random_uniform(UInt32(GlobalVariableManager.shared.playList.count)))
                        self.prepareTune()
                        // 再生アイコン切り替え
                        self.controlButton.setImage(UIImage(named: "playicon"), for: UIControlState())
                    default:
                        GlobalVariableManager.shared.tuneIndex = GlobalVariableManager.shared.tuneIndex! + 1
                        self.prepareTune()
                        // 再生アイコン切り替え
                        self.controlButton.setImage(UIImage(named: "playicon"), for: UIControlState())
                }
            }
        }
    }
    
    // 曲の再生位置操作時の処理
    @IBAction func changePlaybackPositionSlider(_ sender: UISlider) {
        AudioManager.shared.audioBuffer?.currentTime = TimeInterval(self.playbackPositionSlider.value)
    }
    
    // 手動音量調整の為スライダーのvalueをプレイヤーのvolumeに代入
    @IBAction func changeVolumeSlider(_ sender: UISlider) {
        // audioPlayer.volume = volumeSlider.value
        // ユーザー設定のvolumeを保持
        AudioManager.shared.audioVolume = self.volumeSlider.value
        AudioManager.shared.audioBuffer?.volume = AudioManager.shared.audioVolume
    }
    
    @IBAction func pressMinimumVolumeButton(_ sender: UIButton) {
        
        switch AudioManager.shared.audioVolume {
        // 0...nであればnを含み、0..<nであればnを含まない
        case 0.0..<0.11:
            AudioManager.shared.audioVolume = 0
            AudioManager.shared.audioBuffer?.volume = 0
        case 0.11..<0.21:
            AudioManager.shared.audioVolume = 0.1
            AudioManager.shared.audioBuffer?.volume = 0.1
        case 0.21..<0.31:
            AudioManager.shared.audioVolume = 0.2
            AudioManager.shared.audioBuffer?.volume = 0.2
        case 0.31..<0.41:
            AudioManager.shared.audioVolume = 0.3
            AudioManager.shared.audioBuffer?.volume = 0.3
        case 0.41..<0.51:
            AudioManager.shared.audioVolume = 0.4
            AudioManager.shared.audioBuffer?.volume = 0.4
        case 0.51..<0.61:
            AudioManager.shared.audioVolume = 0.5
            AudioManager.shared.audioBuffer?.volume = 0.5
        case 0.61..<0.71:
            AudioManager.shared.audioVolume = 0.6
            AudioManager.shared.audioBuffer?.volume = 0.6
        case 0.71..<0.81:
            AudioManager.shared.audioVolume = 0.7
            AudioManager.shared.audioBuffer?.volume = 0.7
        case 0.81..<0.91:
            AudioManager.shared.audioVolume = 0.8
            AudioManager.shared.audioBuffer?.volume = 0.8
        case 0.91...1.0:
            AudioManager.shared.audioVolume = 0.9
            AudioManager.shared.audioBuffer?.volume = 0.9
        default:
            break
        }
        self.volumeSlider.value = AudioManager.shared.audioVolume
    }
    
    @IBAction func longPressMinimumVolumeButton(_ sender: UILongPressGestureRecognizer) {
        // 押した時点からdurationで設定した秒数経過した時の処理
        if sender.state == .began {
            print("began")
            AudioManager.shared.audioVolume = 0
            AudioManager.shared.audioBuffer?.volume = 0
            self.volumeSlider.value = AudioManager.shared.audioVolume
        }
        // ボタンを話した時の処理
        else if sender.state == .ended {
            print("ended")
        }
    }
    
    @IBAction func pressMaximumVolumeButton(_ sender: UIButton) {
        switch AudioManager.shared.audioVolume {
        // 0...nであればnを含み、0..<nであればnを含まない
        case 0.0..<0.09:
            AudioManager.shared.audioVolume = 0.1
            AudioManager.shared.audioBuffer?.volume = 0.1
        case 0.09..<0.19:
            AudioManager.shared.audioVolume = 0.2
            AudioManager.shared.audioBuffer?.volume = 0.2
        case 0.19..<0.29:
            AudioManager.shared.audioVolume = 0.3
            AudioManager.shared.audioBuffer?.volume = 0.3
        case 0.29..<0.39:
            AudioManager.shared.audioVolume = 0.4
            AudioManager.shared.audioBuffer?.volume = 0.4
        case 0.39..<0.49:
            AudioManager.shared.audioVolume = 0.5
            AudioManager.shared.audioBuffer?.volume = 0.5
        case 0.49..<0.59:
            AudioManager.shared.audioVolume = 0.6
            AudioManager.shared.audioBuffer?.volume = 0.6
        case 0.59..<0.69:
            AudioManager.shared.audioVolume = 0.7
            AudioManager.shared.audioBuffer?.volume = 0.7
        case 0.69..<0.79:
            AudioManager.shared.audioVolume = 0.8
            AudioManager.shared.audioBuffer?.volume = 0.8
        case 0.79..<0.89:
            AudioManager.shared.audioVolume = 0.9
            AudioManager.shared.audioBuffer?.volume = 0.9
        case 0.89...1.0:
            AudioManager.shared.audioVolume = 1.0
            AudioManager.shared.audioBuffer?.volume = 1.0
        default:
            break
        }
        self.volumeSlider.value = AudioManager.shared.audioVolume
    }
    
    @IBAction func longPressMaximumVolumeButton(_ sender: UILongPressGestureRecognizer) {
        // 押した時点からdurationで設定した秒数経過した時の処理
        if sender.state == .began {
            print("began")
            AudioManager.shared.audioVolume = 1
            AudioManager.shared.audioBuffer?.volume = 1
            self.volumeSlider.value = AudioManager.shared.audioVolume
        }
        // ボタンを話した時の処理
        else if sender.state == .ended {
            print("ended")
        }
    }
    
    // オーディオデータの読み込みに伴う処理関数
    func prepareTune() {
        AudioManager.shared.load(fileName: GlobalVariableManager.shared.playList[GlobalVariableManager.shared.tuneIndex][2], fileExtension: GlobalVariableManager.shared.playList[GlobalVariableManager.shared.tuneIndex][3])
        // 曲名とアーティスト名取得
        self.titleLabel.text = GlobalVariableManager.shared.playList[GlobalVariableManager.shared.tuneIndex!][0]
        self.artistLabel.text = GlobalVariableManager.shared.playList[GlobalVariableManager.shared.tuneIndex!][1]
        self.volumeSlider.value = AudioManager.shared.audioVolume
        // スライダーの最大値と音楽ファイルの長さを同期
        // スライダーの値はFloat型になるのでFloat型にキャスト変換
        // duration Type:TimeInterval /The total duration, in seconds, of the sound associated with the audio player
        self.playbackPositionSlider.maximumValue = Float((AudioManager.shared.audioBuffer?.duration)!)
        self.playbackPositionSlider.value = Float((AudioManager.shared.audioBuffer?.currentTime)!)
        self.synchronizeLeftPlaybackPositionLabel(value: (AudioManager.shared.audioBuffer?.currentTime)!)
        self.rightPlaybackPositionLabel.text = convertTimeIntervalToString(value: (AudioManager.shared.audioBuffer?.duration)!)
        switch AudioManager.shared.audioPlayMode {
        case "Normal":
            self.playModeButton.setImage(UIImage(named: "normalmodeicon128"), for: UIControlState())
        case "Repeat":
            self.playModeButton.setImage(UIImage(named: "repeatmodeicon128"), for: UIControlState())
        case "Shuffle":
            self.playModeButton.setImage(UIImage(named: "shufflemodeicon128"), for: UIControlState())
        default:
            break
        }
    }
    
    // playbackPositionSliderのvalueをリアルタイムに書き換える関数
    // 将来的にタイマー関数内で呼び出す処理の追加を想定して関数化する
    func synchronizePlaybackPositionSlider() {
        self.playbackPositionSlider.value = Float((AudioManager.shared.audioBuffer?.currentTime)!)
    }
    
    // leftPlaybackPositionLabelのtextをリアルタイムにプレイヤーのcurrentTimeに書き換える関数
    func synchronizeLeftPlaybackPositionLabel(value: TimeInterval) {
        let formatter = DateFormatter()
        formatter.dateFormat = "mm:ss"
        let returnvalue = formatter.string(from: Date(timeIntervalSinceReferenceDate: value))
        self.leftPlaybackPositionLabel.text = returnvalue
    }
    
    // TimeInterval型をString型に変換する関数
    func convertTimeIntervalToString(value: TimeInterval) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "mm:ss"
        let returnvalue = formatter.string(from: Date(timeIntervalSinceReferenceDate: value))
        return returnvalue
    }
    
    // audioPlayerDidFinishPlayingで終了を検知した際の処理(設計上次の曲を自動再生)
    // PlayModeがシャッフルの場合は次の曲をランダムで自動再生
    func playNextTune() {
        if AudioManager.shared.finishedFlag == true {
            if AudioManager.shared.audioPlayMode == "Normal" || AudioManager.shared.audioPlayMode == "Repeat" {
                if GlobalVariableManager.shared.tuneIndex! == GlobalVariableManager.shared.playList.count - 1 {
                    self.prepareTune()
                    AudioManager.shared.play(volumeValue: AudioManager.shared.audioVolume)
                    // 再生アイコン切り替え
                    self.controlButton.setImage(UIImage(named: "pauseicon"), for: UIControlState())
                } else {
                    GlobalVariableManager.shared.tuneIndex = GlobalVariableManager.shared.tuneIndex! + 1
                    self.prepareTune()
                    AudioManager.shared.play(volumeValue: AudioManager.shared.audioVolume)
                    // 再生アイコン切り替え
                    self.controlButton.setImage(UIImage(named: "pauseicon"), for: UIControlState())
                }
            } else if AudioManager.shared.audioPlayMode == "Shuffle" {
                GlobalVariableManager.shared.tuneIndex = Int(arc4random_uniform(UInt32(GlobalVariableManager.shared.playList.count)))
                print(GlobalVariableManager.shared.tuneIndex)
                self.prepareTune()
                AudioManager.shared.play(volumeValue: AudioManager.shared.audioVolume)
                // 再生アイコン切り替え
                self.controlButton.setImage(UIImage(named: "pauseicon"), for: UIControlState())
            }
            // 終了を検知した際の処理が実行されたらFlagを初期化する
            AudioManager.shared.finishedFlag = false
        }
    }
    
    // PlayMode切り替え時の再読み込み処理
    // 切り替え時に再生中であれば再読み込み後再生
    // 切り替え時に一時停止中であれば再読み込み後一時停止
    func reloadTune() {
        if (AudioManager.shared.audioBuffer?.isPlaying)! {
            AudioManager.shared.audioBuffer?.pause()
            self.changedPlayModeTime = AudioManager.shared.audioBuffer?.currentTime
            self.playbackPositionSlider.value = Float(self.changedPlayModeTime)
            self.synchronizeLeftPlaybackPositionLabel(value: self.changedPlayModeTime)
            AudioManager.shared.play(volumeValue: AudioManager.shared.audioVolume)
        } else {
            self.changedPlayModeTime = AudioManager.shared.audioBuffer?.currentTime
            self.playbackPositionSlider.value = Float(self.changedPlayModeTime)
            self.synchronizeLeftPlaybackPositionLabel(value: self.changedPlayModeTime)
        }
    }
}
