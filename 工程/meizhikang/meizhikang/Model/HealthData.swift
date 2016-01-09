//
//  HealthData.swift
//  meizhikang
//
//  Created by 刘向宏 on 15/12/23.
//  Copyright © 2015年 刘向宏. All rights reserved.
//

import Foundation
import CoreData


class HealthData: NSManagedObject {

// Insert code here to add functionality to your managed object subclass

    func helathColor() -> UIColor?{
        return UIColor.helathColorByValue((healthValue?.integerValue)!)
    }
    
    func helathString() -> String?{
        let value = healthValue?.integerValue
        //0-59为不健康，60-69为体弱，70-79为亚健康，80-100为健康
        if (value >= 80) {
            return "健康";
        }
        else if (value>=70) {
            return "亚健康";
        }
        else if (value>=60) {
            return "体弱";
        }
        else{
            return "不健康";
        }
    }
}
