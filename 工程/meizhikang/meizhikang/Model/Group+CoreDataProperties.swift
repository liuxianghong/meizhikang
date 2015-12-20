//
//  Group+CoreDataProperties.swift
//  meizhikang
//
//  Created by 刘向宏 on 15/12/20.
//  Copyright © 2015年 刘向宏. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Group {

    @NSManaged var createtime: NSNumber?
    @NSManaged var etag: NSNumber?
    @NSManaged var gid: NSNumber?
    @NSManaged var gname: String?
    @NSManaged var owner: NSNumber?
    @NSManaged var messages: NSSet?
    @NSManaged var user: NSSet?

}
