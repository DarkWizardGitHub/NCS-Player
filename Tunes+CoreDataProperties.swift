//
//  Tunes+CoreDataProperties.swift
//  NCS Player
//
//  Created by Dark on 2018/06/14.
//  Copyright © 2018年 Dark. All rights reserved.
//
//

// Create NSManagedObject Subclass作成の際にCodegenを「Manual/None」に変更必要(Class Definitionだとエラー)
import Foundation
import CoreData


extension Tunes {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Tunes> {
        return NSFetchRequest<Tunes>(entityName: "Tunes")
    }

    @NSManaged public var tune_name: String?
    @NSManaged public var artist_name: String?
    @NSManaged public var tune_path: String?

}
