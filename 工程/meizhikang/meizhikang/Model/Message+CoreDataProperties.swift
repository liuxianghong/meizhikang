//
//  Message+CoreDataProperties.swift
//  meizhikang
//
//  Created by 刘向宏 on 16/1/12.
//  Copyright © 2016年 刘向宏. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Message {

    @NSManaged var content: String?
    @NSManaged var data: NSData?
    @NSManaged var filepath: String?
    @NSManaged var fromid: NSNumber?
    @NSManaged var gid: NSNumber?
    @NSManaged var pushtype: String?
    @NSManaged var sendtime: NSNumber?
    @NSManaged var uuid: NSNumber?
    @NSManaged var group: Group?
    @NSManaged var chat: Chat?

}
