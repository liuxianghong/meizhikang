//
//  GroupMember+CoreDataProperties.swift
//  meizhikang
//
//  Created by 刘向宏 on 15/12/21.
//  Copyright © 2015年 刘向宏. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension GroupMember {

    @NSManaged var uid: NSNumber?
    @NSManaged var nickname: String?
    @NSManaged var createtime: NSNumber?
    @NSManaged var groups: NSSet?

}
