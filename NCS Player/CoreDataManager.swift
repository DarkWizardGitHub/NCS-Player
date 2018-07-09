//
//  CoreDataManager.swift
//  NCS Player
//
//  Created by Dark on 2018/06/14.
//  Copyright © 2018年 Dark. All rights reserved.
//  Special thanks to Yuka Okada, Reo Okumura.
//

import UIKit
import CoreData

// 関数のオーバーロードを避ける為ジェネリクス型で定義
class CoreDataManager<T>: NSObject {
    
    let entityName: String
    var attributes: [T] = []
    
    init(setEntityName: String, attributeNames: [T]) {
        self.entityName = setEntityName
        self.attributes = attributeNames
        
        // ①ここにREOさんが指摘してくれているAppDelegateとContextの処理を記述し共通化
//        // AppDelegateのインスタンス化
//        let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
//        // コンテキストを取得
//        let context = appDelegate.persistentContainer.viewContext
        
    }
    
    
    // Create処理
    func create(values: [T]) {
        // AppDelegateのインスタンス化
        let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
        // コンテキストを取得
        let context = appDelegate.persistentContainer.viewContext
        // エンティティ
        let entity = NSEntityDescription.entity(forEntityName: entityName, in: context)
        // contextに１レコード追加
        let newRecord = NSManagedObject(entity: entity!, insertInto: context)
        // エンティティ内のアトリビュート数と引数に渡された配列の要素数の整合性確認
        if self.attributes.count == values.count {
            // レコードに値の設定
            for i in 0..<values.count {
                newRecord.setValue(values[i], forKey: attributes[i] as! String)
            }
        } else {
//            エラー処理書きましょう
            print("error")
            return
        }
        
        // 保存
        do {
            try context.save()
        } catch  {
            print("error:",error)
        }
    }
    

    // ②Reoさん指摘のReadBy処理
    func readBy(id: Int) {
        
    }
    
    // ③Reoさん指摘のReadAll処理
    func readAll() -> [Any] {
        var fetchedArry: [NSManagedObject] = []
        var record: [Any] = []
        var returnArry: [Any] = []
        
        // AppDelegateのインスタンス化
        let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
        // コンテキストを取得
        let context = appDelegate.persistentContainer.viewContext
        // データをフェッチ
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        
        do {
            // データ取得 配列で取得される
            fetchedArry = try context.fetch(fetchRequest) as! [NSManagedObject]
        } catch {
            print("read error:",error)
        }
        
        for buffer in fetchedArry {
            for i in 0...GlobalVariableManager.shared.coreDataAttributes.count - 1 {
                record.append(buffer.value(forKey: GlobalVariableManager.shared.coreDataAttributes[i]))
            }
            returnArry.append(record)
            // データ追加時に取得したメモリ空間を残しておく場合は引数にtrue
            // 削除、追加を繰り返す場合はメモリ空間を残しておいたほうが余計なメモリ取得処理が行われない
            record.removeAll(keepingCapacity: true)
        }
        return returnArry
    }
    
    
    
    
    
    
    
    
    
    // Read(sort)処理
    func sortRead(attribute: String, ascending: Bool, numberOfLimit: Int = 0) -> [Any] {
//    以下ジェネリクス型検討中
//    func sortRead<T>(attribute: String, ascending: Bool, numberOfLimit: Int = 0) -> [T] {
//    func sortRead<T>(attribute: T, ascending: Bool, numberOfLimit: Int = 0) -> [T] {
        var fetchedArry: [NSManagedObject] = []
        var record: [Any] = []
        var returnArry: [Any] = []

        // AppDelegateのインスタンス化
        let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
        // コンテキストを取得
        let context = appDelegate.persistentContainer.viewContext
        // データをフェッチ
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        // 並び替え
        let sortDescriptor = NSSortDescriptor(key: attribute, ascending: ascending) // true:昇順　false 降順
//        let sortDescriptor = NSSortDescriptor(key: attribute as! String, ascending: ascending)
        fetchRequest.sortDescriptors = [sortDescriptor]
        //フェッチ件数の制限
        if numberOfLimit >= 1 {
            fetchRequest.fetchLimit = numberOfLimit
        }
        
        do {
            // データ取得 配列で取得される
            fetchedArry = try context.fetch(fetchRequest) as! [NSManagedObject]
        } catch {
            print("read error:",error)
        }
        
// ④返り値と下記のAny型がすごく気になる、どうすればいいか質問する
//        Reoさん案
//        return fetchedArry.map { $0 as! T }
        for buffer in fetchedArry {
            for i in 0...GlobalVariableManager.shared.coreDataAttributes.count - 1 {
                record.append(buffer.value(forKey: GlobalVariableManager.shared.coreDataAttributes[i]))
            }
            returnArry.append(record)
            // データ追加時に取得したメモリ空間を残しておく場合は引数にtrue
            // 削除、追加を繰り返す場合はメモリ空間を残しておいたほうが余計なメモリ取得処理が行われない
            record.removeAll(keepingCapacity: true)
        }
        return returnArry
    }
    
    
    // Read(predicate)処理
    func predicateRead(attribute: String, relationalOperator: String, placeholder: String, targetValue: T, numberOfLimit: Int = 0) -> [Any] {
        
        var fetchedArry: [NSManagedObject] = []
        var record: [Any] = []
        var returnArry: [Any] = []
        
        // AppDelegateのインスタンス化
        let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
        // コンテキストを取得
        let context = appDelegate.persistentContainer.viewContext
        // データをフェッチ
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        // 絞り込み
        let predicate = NSPredicate(format: "\(attribute) \(relationalOperator) \(placeholder)", targetValue as! CVarArg)
        fetchRequest.predicate = predicate
        //フェッチ件数の制限
        if numberOfLimit >= 1 {
            fetchRequest.fetchLimit = numberOfLimit
        }
        
        do {
            // データ取得 配列で取得される
            fetchedArry = try context.fetch(fetchRequest) as! [NSManagedObject]
        } catch {
            print("read error:",error)
        }
        
        for buffer in fetchedArry {
            for i in 0...GlobalVariableManager.shared.coreDataAttributes.count - 1 {
                record.append(buffer.value(forKey: GlobalVariableManager.shared.coreDataAttributes[i]))
            }
            returnArry.append(record)
            // データ追加時に取得したメモリ空間を残しておく場合は引数にtrue
            // 削除、追加を繰り返す場合はメモリ空間を残しておいたほうが余計なメモリ取得処理が行われない
            record.removeAll(keepingCapacity: true)
        }
        return returnArry
    }
    
    
    // Update処理
    func update(attribute: String, relationalOperator: String, placeholder: String, targetValue: T, values: [T]) {
        
        var fetchedArry: [NSManagedObject] = []
        
        // AppDelegateのインスタンス化
        let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
        // コンテキストを取得
        let context = appDelegate.persistentContainer.viewContext
        // データをフェッチ
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        // (更新データの)絞り込み
        let predicate = NSPredicate(format: "\(attribute) \(relationalOperator) \(placeholder)", targetValue as! CVarArg)
        fetchRequest.predicate = predicate
        do {
            // データ取得 配列で取得される
            fetchedArry = try context.fetch(fetchRequest) as! [NSManagedObject]
        } catch  {
            print("read error:",error)
        }
//        NSManagedObject型 NSFetchRequestResult型の違いを調べる
        if self.attributes.count == values.count {
            // レコードに値の設定
            for i in 0..<fetchedArry.count {
                for n in 0..<values.count {
                    fetchedArry[i].setValue(values[n], forKey: attributes[n] as! String)
                }
            }
        } else {
            print("error")
            return
        }
        // 保存
        do {
            try context.save()
        } catch  {
            print("read error:",error)
        }
    }
    
    
    // Delete処理
    func delete(attribute: String, relationalOperator: String, placeholder: String, targetValue: T) {
        
        var fetchedArry: [NSManagedObject] = []
        
        // AppDelegateのインスタンス化
        let appDelegate:AppDelegate = UIApplication.shared.delegate as! AppDelegate
        // コンテキストを取得
        let context = appDelegate.persistentContainer.viewContext
        // データをフェッチ
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        // 絞り込み
//        let predicate = NSPredicate(format: "\(attribute) = \(placeholder)", string)
        let predicate = NSPredicate(format: "\(attribute) \(relationalOperator) \(placeholder)", targetValue as! CVarArg)
        fetchRequest.predicate = predicate
        do {
            // データ取得 配列で取得される
            fetchedArry = try context.fetch(fetchRequest) as! [NSManagedObject]
            // context.delete(fetchResults.first!) 一行だけ削除するなら、この書き方でも良い
        } catch  {
            print("read error:",error)
        }
        
        // 同キーワードのデータ(1レコード)も削除
        for result in fetchedArry {
            context.delete(result as! NSManagedObject)
        }
        // 保存
        do {
            try context.save()
        } catch  {
            print("read error:",error)
        }
    }
}
