//
//  Groups.swift
//  meizhikang
//
//  Created by 刘向宏 on 15/12/19.
//  Copyright © 2015年 刘向宏. All rights reserved.
//

import Foundation
import CoreData

@objc(Group)
class Group: NSManagedObject {

// Insert code here to add functionality to your managed object subclass
    static func GroupByGid(gid : AnyObject) -> Group?{
        
        if let user = Group.MR_findByAttribute("gid", withValue: gid).first as? Group{
            return user;
        }
        else{
            let user = Group.MR_createEntity()
            user.gid = gid as? NSNumber
            return user
        }
    }
    
    func upDateGroupInfo(dic : [String : AnyObject]){
        
        if members?.count == 0{
            updateMembersChanges()
        }
        else if etag != nil{
            if !etag!.isEqualToNumber(dic["etag"] as! NSNumber){
                updateMembersChanges()
            }
        }
        etag = dic["etag"] as? NSNumber
        createtime = dic["createtime"] as? NSNumber
        gname = dic["gname"] as? String
        owner = dic["owner"] as? NSNumber
        
    }
    
    func updateMembersChanges(){
        IMRequst.GetMembersGroupByGid(gid, completion: { (object) -> Void in
            print(object)
            let json = JSON(object)
            if !json["gid"].number!.isEqualToNumber(self.gid!){
                return
            }
            let array = json["members"].arrayValue
            for dic:JSON in array{
                let member = GroupMember.GroupMemberByUid(dic["uid"].numberValue)
                member?.upDateGroupInfo(dic.dictionaryObject!)
                if !member!.groups!.containsObject(self){
                    let ms = member?.groups as! NSMutableSet
                    ms.addObject(self)
                }
            }
            NSManagedObjectContext.MR_defaultContext().MR_saveToPersistentStoreWithCompletion(nil)
            }) { (error : NSError!) -> Void in
                
        }
    }
    
//    func messages() -> [Message]{
//        let predicateTemplate = NSPredicate(format: "time <=  %@ AND time >= %@ AND group = %@", maxTime,minTime,self)
//        return Message.MR_findAllSortedBy("sendtime", ascending: true, withPredicate: predicateTemplate) as? [HealthData]
//    }

}
