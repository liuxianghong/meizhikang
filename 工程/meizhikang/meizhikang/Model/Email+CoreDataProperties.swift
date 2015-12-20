//
//  Email+CoreDataProperties.swift
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

extension Email {

    @NSManaged var fromid: NSNumber?
    @NSManaged var sendtime: NSNumber?
    @NSManaged var title: String?
    @NSManaged var uuid: NSNumber?
    @NSManaged var content: String?
    @NSManaged var user: User?

}
