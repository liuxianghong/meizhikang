//
//  Message+CoreDataProperties.swift
//  meizhikang
//
//  Created by shadowPriest on 15/12/20.
//  Copyright © 2015年 刘向宏. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Message {

    @NSManaged var uuid: NSNumber?
    @NSManaged var content: String?
    @NSManaged var sendtime: NSNumber?
    @NSManaged var pushtype: String?
    @NSManaged var fromid: NSNumber?
    @NSManaged var gid: NSNumber?
    @NSManaged var group: Group?

}
