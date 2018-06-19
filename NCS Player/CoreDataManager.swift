//
//  CoreDataManager.swift
//  NCS Player
//
//  Created by Dark on 2018/06/14.
//  Copyright © 2018年 Dark. All rights reserved.
//

import UIKit
import CoreData

class CoreDataManager: NSObject {
    
    let entityName: String
    var attributes: [String] = []
    
    init(setEntityName: String, attributeNames: [String]) {
        self.entityName = setEntityName
        self.attributes = attributeNames
    }
    
    
    // Create処理
    func create(values: [String]) {
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
            for i in 0...values.count - 1 {
                newRecord.setValue(values[i], forKey: attributes[i])
            }
        } else {
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
    
    
    // Read(sort)処理
    func sortRead(attribute: String, ascending: Bool, numberOfLimit: Int = 0) -> (Any) { // NSManagedObject型で返したいがAny型じゃないとエラー
        var fetchedArry: [NSManagedObject] = []

        // AppDelegateのインスタンス化
        let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
        // コンテキストを取得
        let context = appDelegate.persistentContainer.viewContext
        // データをフェッチ
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        // 並び替え
        let sortDescriptor = NSSortDescriptor(key: attribute, ascending: ascending) // true:昇順　false 降順
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
        
// 返り値と下記のAny型がすごく気になる、どうすればいいか質問する
        var record: [Any] = []
        var returnArry: [Any] = []
        for buffer in fetchedArry {
            for i in 0...GlobalVariableManager.shared.coreDataAttributes.count - 1 {
//                print(i)
// record[i] = buffer.value(forKey: GlobalVariableManager.shared.coreDataAttributes[i])では要素追加できないんだっけか？
                record.append(buffer.value(forKey: GlobalVariableManager.shared.coreDataAttributes[i]))
            }
            print("returnArryに格納")
            print("recordの値\(record)")
            returnArry.append(record)
            print("returnArryの値\(returnArry)")
            print("record初期化")
            // データ追加時に取得したメモリ空間を残しておく場合は引数にtrue
            // 削除、追加を繰り返す場合はメモリ空間を残しておいたほうが余計なメモリ取得処理が行われない
            record.removeAll(keepingCapacity: true)
        }
//        returnArryはAny型？これでいいのか質問する
        return returnArry
    }
    
    
    // Read(predicate)処理
    func predicateRead(attribute: String, placeholder: String, string: String, numberOfLimit: Int = 0) -> (Any) {
        
        var fetchedArry: [NSManagedObject] = []
        
        // AppDelegateのインスタンス化
        let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
        // コンテキストを取得
        let context = appDelegate.persistentContainer.viewContext
        // データをフェッチ
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        //        以下のSweetMemoryに該当する箇所を動的に書き換えたい、しかし<>内がObjectになっていると推察されString(今回はエンティティ名を想定)ではない為授業の書き方ではエラーになる
        //        let fetchRequest:NSFetchRequest<SweetMemory> = SweetMemory.fetchRequest()
        // 絞り込み
        let predicate = NSPredicate(format: "\(attribute) = \(placeholder)", string)
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
        
        var record: [Any] = []
        var returnArry: [Any] = []
        for buffer in fetchedArry {
            for i in 0...GlobalVariableManager.shared.coreDataAttributes.count - 1 {
                print(i)
                record.append(buffer.value(forKey: GlobalVariableManager.shared.coreDataAttributes[i]))
            }
            print("returnArryに格納")
            print("recordの値\(record)")
            returnArry.append(record)
            print("returnArryの値\(returnArry)")
            print("record初期化")
            // データ追加時に取得したメモリ空間を残しておく場合は引数にtrue
            // 削除、追加を繰り返す場合はメモリ空間を残しておいたほうが余計なメモリ取得処理が行われない
            record.removeAll(keepingCapacity: true)
        }
        return returnArry
    }
    
    
    // Update処理
    func update(attribute: String, placeholder: String, string: String, values: [String]) {
        
        var fetchedArry: [NSManagedObject] = []
        
        // AppDelegateのインスタンス化
        let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
        // コンテキストを取得
        let context = appDelegate.persistentContainer.viewContext
        // データをフェッチ
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        // (更新データの)絞り込み
        let predicate = NSPredicate(format: "\(attribute) = \(placeholder)", string)
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
            for i in 0...fetchedArry.count - 1 {
                for n in 0...values.count - 1 {
                    fetchedArry[i].setValue(values[n], forKey: attributes[n])
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
    func delete(attribute: String, placeholder: String, string: String) {
        
        var fetchedArry: [NSManagedObject] = []
        
        // AppDelegateのインスタンス化
        let appDelegate:AppDelegate = UIApplication.shared.delegate as! AppDelegate
        // コンテキストを取得
        let context = appDelegate.persistentContainer.viewContext
        // データをフェッチ
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        // 絞り込み
//        let predicate = NSPredicate(format: "\(attribute) = \(placeholder)", string)
        let predicate = NSPredicate(format: "\(attribute) = \(placeholder)", string)
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
