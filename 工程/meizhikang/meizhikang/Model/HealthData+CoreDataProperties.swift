//
//  HealthData+CoreDataProperties.swift
//  meizhikang
//
//  Created by 刘向宏 on 15/12/23.
//  Copyright © 2015年 刘向宏. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension HealthData {

    @NSManaged var heartRate: NSNumber?
    @NSManaged var healthValue: NSNumber?
    @NSManaged var time: NSDate?
    @NSManaged var user: User?

}
