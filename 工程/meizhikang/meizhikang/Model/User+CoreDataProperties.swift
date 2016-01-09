//
//  User+CoreDataProperties.swift
//  meizhikang
//
//  Created by 刘向宏 on 16/1/9.
//  Copyright © 2016年 刘向宏. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension User {

    @NSManaged var avatar: String?
    @NSManaged var createtime: NSNumber?
    @NSManaged var gid: NSNumber?
    @NSManaged var height: NSNumber?
    @NSManaged var nickname: String?
    @NSManaged var old: NSNumber?
    @NSManaged var passWord: String?
    @NSManaged var phone: String?
    @NSManaged var roleid: NSNumber?
    @NSManaged var sex: NSNumber?
    @NSManaged var uid: NSNumber?
    @NSManaged var userName: String?
    @NSManaged var weight: NSNumber?
    @NSManaged var heartCommand: NSNumber?
    @NSManaged var emails: NSSet?
    @NSManaged var groups: NSSet?
    @NSManaged var healthDatas: NSSet?

}
