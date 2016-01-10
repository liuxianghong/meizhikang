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
            user.heartCommand = 60
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
        
        loadGrous()
        
        let dic = ["type":"get_email","page":1 ,"number":20]
        IMRequst.RequstUserInfo(dic, completion: { (object) -> Void in
            print(object)
            
            }) { (error : NSError!) -> Void in
                
        }
        
        let dic2 = ["type":"messages","page":1 ,"number":20]
        IMRequst.RequstUserInfo(dic2, completion: { (object) -> Void in
            print(object)
            
            }) { (error : NSError!) -> Void in
                
        }
        
    }
    
    
    func healthDatas(minTime : NSDate ,maxTime : NSDate) -> [HealthData]?{
        let predicateTemplate = NSPredicate(format: "time <=  %@ AND time >= %@ AND user = %@", maxTime,minTime,self)
        return HealthData.MR_findAllSortedBy("time", ascending: true, withPredicate: predicateTemplate) as? [HealthData]
    }
    
    func healthDatasOneDay(date : NSDate) -> [HealthData]?{
        guard
            let currentDay = NSCalendar.currentCalendar().dateBySettingHour(0, minute: 0, second: 0, ofDate: date, options: NSCalendarOptions(rawValue: 0)),
            let nextDay = NSCalendar.currentCalendar().dateByAddingUnit(.Day, value: 1, toDate: currentDay, options: NSCalendarOptions(rawValue: 0))else{
                return nil
        }
        return self.healthDatas(currentDay, maxTime: nextDay)
    }
    
    func groupByID(gid : NSNumber) -> Group?{
        for group in groups!{
            let g = group as! Group
            if g.gid!.isEqualToNumber(gid){
                return g
            }
        }
        return nil
    }
    
    func loadGrous(){
        let dic = ["type":"groups"]
        IMRequst.RequstUserInfo(dic, completion: { (object) -> Void in
            print(object)
            let json = JSON(object)
            let groups = json["groups"].arrayValue
            let user = UserInfo.CurrentUser()
            user?.groups = nil
            for groupDic in groups{
                let dd = groupDic.dictionaryValue
                if dd.count != 0{
                    let group = Group.GroupByGid((dd["gid"]?.object)!)
                    group?.upDateGroupInfo(groupDic.dictionaryObject!)
                    if !(group!.user?.containsObject(user!))!{
                        let users = group!.mutableSetValueForKey("user")
                        users.addObject(user!)
                    }
                }
            }
            NSManagedObjectContext.MR_defaultContext().MR_saveToPersistentStoreAndWait()
            NSNotificationCenter.defaultCenter().postNotificationName("groupChangeNotification", object: nil)
            
            }, failure: { (error : NSError!) -> Void in
        })
    }
    
}
