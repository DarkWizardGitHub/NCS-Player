//
//  AppDelegate.swift
//  NCS Player
//
//  Created by Dark on 2018/05/29.
//  Copyright © 2018年 Dark. All rights reserved.
//

import UIKit
// CoreData使用
import CoreData
import AVFoundation

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        // ユーザーデフォルトインスタンス(参照)
         let userDefaults = UserDefaults.standard
        // 値を取り出す前に.register()メソッドを用いることで初期値を指定
        // 初期値の指定をしない場合、UserDefaultsではそのデータ型の基本値(Intなら0、Boolならfalse)が初回の呼び出しで取得
        // 一度も利用されていない(保存されていない)Keyのデータに適応、値がすでに入っているときはそちらを優先し、初期値は無視
        // 初回起動時に機能制限用フラグ変数の初期化
        userDefaults.register(defaults: ["Restrictions": false])
        
        // アプリのversionとbuild番号表示
        let version: String! = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
        let build: String! = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as! String
        print("""
            ***** Application Version *****
            version: \(version!)
            build: \(build!)
            """)
        
        // CoreData使用の為追記
        // CoreDataに使用されているSQLiteファイル保存パス確認用
        let path = NSSearchPathForDirectoriesInDomains(.applicationSupportDirectory, .userDomainMask, true)
        // Swift4から「"""」で文字列を囲むことで、複数行の文字列の表示が可能
        print("""
            ***** SQLite file path for Core Data *****
            \(path)
            """)
        
        // バックグラウンド再生の為追記
        try? AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback, with: .mixWithOthers)
        try? AVAudioSession.sharedInstance().setActive(true)
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // CoreData使用の為追記
        self.saveContext()
    }
    
    // CoreData使用の為追記
    // MARK: - Core Data stack
    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
         */
        let container = NSPersistentContainer(name: "Tunes")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    // CoreData使用の為追記
    // MARK: - Core Data Saving support
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    // LaunchScreenでロゴを見せつける為追記
    func application(_ application: UIApplication, willFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey : Any]? = nil) -> Bool {
        Thread.sleep(forTimeInterval: 2.0)
        return true
    }
}

