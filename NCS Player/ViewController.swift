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

    var audioPlayer: AVAudioPlayer!
    var playTimer: Timer!
    
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
    lazy var Tunes = [tune0, tune1, tune2, tune3, tune4]
//    var Tunes = [Bundle.main.path(forResource: "Ehrling-Sthlm Sunset", ofType:"mp3")!, Bundle.main.path(forResource: "Itro & Tobu-Cloud 9", ofType:"mp3")!]

    var recievedIndex: Int? = nil
    
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
        print(Tunes.count)
        // 音楽ファイルとパスをviewDidLoad内に置くことで一時停止しても途中から再生再開
        // ここも便宜的に曲を指定しているが、将来的には大量の曲数を処理するフローを検討
        let audioUrl = URL(fileURLWithPath: Tunes[recievedIndex!].tunePath!)
        var audioError:NSError?
        do {
            // auido を再生するプレイヤーを作成
            audioPlayer = try AVAudioPlayer(contentsOf: audioUrl)
            
            // スライダーの最大値と音楽ファイルの長さを同期
            // スライダーの値はFloat型になるのでFloat型にキャスト変換
            // duration Type:TimeInterval /The total duration, in seconds, of the sound associated with the audio player
            playbackPositionSlider.maximumValue = Float(audioPlayer.duration)
        } catch let error as NSError {
            audioError = error
            audioPlayer = nil
        }
        
        // playbackPositionSliderの設定
        // スライダー非操作時の画像
        playbackPositionSlider.setThumbImage(UIImage(named: "playbackpositioncursor"), for: .normal)
        // スライダー操作時の画像
        playbackPositionSlider.setThumbImage(UIImage(named: "playbackpositioncursor"), for: .highlighted)
        rightPlaybackPositionLabel.text = convertTimeIntervalToString(value: audioPlayer.duration)
        titleLabel.text = Tunes[recievedIndex!].tuneName
        artistLabel.text = Tunes[recievedIndex!].artistName
        
        // Timerで1秒毎にプレイヤーのcurrentTimeとスライダーのvalueを同期、leftPlaybackPositionLabelのtextをプレイヤーのcurrentTimeと同期
        playTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true, block: {(action) in
            self.changePlaybackPositionSlider()
            self.changeLeftPlaybackPositionLabel(value: self.audioPlayer.currentTime)
        })

        // エラー処理
        if let error = audioError {
            print("Error \(error.localizedDescription)")
        }
        
        audioPlayer.delegate = self
        audioPlayer.prepareToPlay()
        
//        おかゆさんに聞くこと１
//        ここのデリゲートの意味
        // willShowを使用して、NavigationControllerのBackを押した動作をハンドリングする為
        navigationController?.delegate = self
    }
    
    @IBOutlet var bar: UIView!
    @IBOutlet weak var sl: UISlider!
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    // backボタンを押すと以下の２パターンの処理を行う
    // 再生中→音楽の再生位置はリセットされ1個前の曲の頭から演奏が始まる
    // 一時停止中→音楽の再生位置はリセットされ1個前の曲の頭で一時停止する
    // プレイリストの先頭の場合のみ再度その曲を選択する
    @IBAction func backButton(_ sender: UIButton) {
        if (audioPlayer.isPlaying){
            if recievedIndex! == 0 {
                loadView()
                viewDidLoad()
                audioPlayer.play()
                // 再生アイコン切り替え
                controlButton.setImage(UIImage(named: "pauseicon"), for: UIControlState())
            } else {
                recievedIndex = recievedIndex! - 1
                loadView()
                viewDidLoad()
                audioPlayer.play()
                // 再生アイコン切り替え
                controlButton.setImage(UIImage(named: "pauseicon"), for: UIControlState())
            }
        } else {
            if recievedIndex! == 0 {
                loadView()
                viewDidLoad()
                // 一時停止アイコン切り替え
                controlButton.setImage(UIImage(named: "playicon"), for: UIControlState())
            } else {
                recievedIndex = recievedIndex! - 1
                loadView()
                viewDidLoad()
                // 一時停止アイコン切り替え
                controlButton.setImage(UIImage(named: "playicon"), for: UIControlState())
            }
        }
    }
    
    @IBAction func controlButton(_ sender: UIButton) {
        if (audioPlayer.isPlaying){
            // 一時停止
            audioPlayer.stop()
            // 再生アイコン切り替え
            controlButton.setImage(UIImage(named: "playicon"), for: UIControlState())
        } else {
            // 再生
            audioPlayer.play()
            // 一時停止アイコン切り替え
            controlButton.setImage(UIImage(named: "pauseicon"), for: UIControlState())
        }
    }
    
    // nextボタンを押すと以下の２パターンの処理を行う
    // 再生中→音楽の再生位置はリセットされ1個後の曲の頭から演奏が始まる
    // 一時停止中→音楽の再生位置はリセットされ1個後の曲の頭で一時停止する
    // プレイリストの末尾の場合のみ再度その曲を選択する
    @IBAction func nextButton(_ sender: UIButton) {
        if (audioPlayer.isPlaying){
            if recievedIndex! == Tunes.count - 1 {
                print(Tunes.count)
                loadView()
                viewDidLoad()
                audioPlayer.play()
                // 再生アイコン切り替え
                controlButton.setImage(UIImage(named: "pauseicon"), for: UIControlState())
            } else {
                recievedIndex = recievedIndex! + 1
                loadView()
                viewDidLoad()
                audioPlayer.play()
                // 再生アイコン切り替え
                controlButton.setImage(UIImage(named: "pauseicon"), for: UIControlState())
            }
        } else {
            if recievedIndex! == Tunes.count - 1 {
                loadView()
                viewDidLoad()
                // 一時停止アイコン切り替え
                controlButton.setImage(UIImage(named: "playicon"), for: UIControlState())
            } else {
                recievedIndex = recievedIndex! + 1
                loadView()
                viewDidLoad()
                // 一時停止アイコン切り替え
                controlButton.setImage(UIImage(named: "playicon"), for: UIControlState())
            }
        }
    }
    
    @IBAction func playbackPositionSlider(_ sender: UISlider) {
        audioPlayer.currentTime = TimeInterval(playbackPositionSlider.value)
    }
    
    // 手動音量調整の為スライダーのvalueをプレイヤーのvolumeに代入
    @IBAction func volumeSlider(_ sender: UISlider) {
        audioPlayer.volume = volumeSlider.value
    }
    
    // playbackPositionSliderのvalueをリアルタイムに書き換える関数
    func changePlaybackPositionSlider() {
        playbackPositionSlider.value = Float(audioPlayer.currentTime)
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
    
    // navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) は、その画面から別の画面に遷移したときに呼ばれるメソッド
    // →「遷移先から遷移元に遷移した時をハンドリング」
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        if viewController is Best30PlayListViewController {
            playTimer = nil
            audioPlayer = nil
//        おかゆさんに聞くこと2
//        以下の処理を入れないとエラーになる
//        playTimerがaudioPlayerを破棄した後も動作せいている為audioPlayer.currentTimeの値が取得できずにエラーが発生していると考え
//            playTimer自体もaudioPlayerを破棄前に破棄を試みたがエラー発生、破棄したがタイマーの処理が止まっていないためか？
//            とりあえず以下を読み込むことでaudioPlayerが作成されるため該当箇所のエラーを回避している状態と推察。
//            でも根本的な解決になっているのだろうか？
            loadView()
            viewDidLoad()
        }
    }
}

