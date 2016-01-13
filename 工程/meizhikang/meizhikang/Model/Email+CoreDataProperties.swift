//
//  Email+CoreDataProperties.swift
//  meizhikang
//
//  Created by 刘向宏 on 16/1/13.
//  Copyright © 2016年 刘向宏. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Email {

    @NSManaged var content: String?
    @NSManaged var fromid: NSNumber?
    @NSManaged var sendtime: NSNumber?
    @NSManaged var title: String?
    @NSManaged var uuid: NSNumber?
    @NSManaged var uid: NSNumber?
    @NSManaged var gid: NSNumber?
    @NSManaged var user: User?

}
