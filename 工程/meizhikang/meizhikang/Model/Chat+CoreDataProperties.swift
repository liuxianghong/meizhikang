//
//  Chat+CoreDataProperties.swift
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

extension Chat {

    @NSManaged var unReadMessage: NSNumber?
    @NSManaged var user: User?
    @NSManaged var messages: NSSet?
    @NSManaged var member: GroupMember?

}
