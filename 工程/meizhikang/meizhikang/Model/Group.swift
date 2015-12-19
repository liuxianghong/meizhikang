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
        createtime = dic["createtime"] as? NSNumber
        etag = dic["etag"] as? NSNumber
        gname = dic["gname"] as? String
        owner = dic["owner"] as? NSNumber
    }

}
