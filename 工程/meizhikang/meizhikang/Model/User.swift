//
//  User.swift
//  meizhikang
//
//  Created by 刘向宏 on 15/12/19.
//  Copyright © 2015年 刘向宏. All rights reserved.
//

import Foundation
import CoreData

@objc(User)
class User: NSManagedObject {

// Insert code here to add functionality to your managed object subclass
    static func userByUid(uid : AnyObject) -> User?{
        
        if let user = User.MR_findByAttribute("uid", withValue: uid).first as? User{
            return user;
        }
        else{
            let user = User.MR_createEntity()
            user.uid = uid as? NSNumber
            return user
        }
    }
    
    
    func upDateUserInfo(dic : [String : AnyObject]){
        nickname = dic["nickname"] as? String
        roleid = dic["roleid"] as? NSNumber
        phone = dic["phone"] as? String
        createtime = dic["createtime"] as? NSNumber
        height = dic["height"] as? NSNumber
        weight = dic["weight"] as? NSNumber
        old = dic["old"] as? NSNumber
        
        sex = dic["sex"] as? NSNumber
        gid = dic["gid"] as? NSNumber
        avatar = dic["avatar"] as? String
        
    }
    
    
    func healthDatas(minTime : NSDate ,maxTime : NSDate) -> [HealthData]?{
        let predicateTemplate = NSPredicate(format: "time <=  %@ AND time >= %@ AND user = %@", maxTime,minTime,self)
        return HealthData.MR_findAllSortedBy("time", ascending: true, withPredicate: predicateTemplate) as? [HealthData]
    }
    
    func healthDatasOneDay(date : NSDate) -> [HealthData]?{
        let formatter = NSDateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let fstr = formatter.stringFromDate(date)
        let minDate = "\(fstr) 00:00:00"
        let maxDate = "\(fstr) 23:59:59"
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return healthDatas(formatter.dateFromString(minDate)!, maxTime: formatter.dateFromString(maxDate)!)
    }

}
