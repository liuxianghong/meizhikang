//
//  GroupMember.swift
//  meizhikang
//
//  Created by 刘向宏 on 15/12/21.
//  Copyright © 2015年 刘向宏. All rights reserved.
//

import Foundation
import CoreData


class GroupMember: NSManagedObject {

// Insert code here to add functionality to your managed object subclass
    static func GroupMemberByUid(uid : AnyObject) -> GroupMember?{
        
        if let user = GroupMember.MR_findByAttribute("uid", withValue: uid).first as? GroupMember{
            return user;
        }
        else{
            let user = GroupMember.MR_createEntity()
            user.uid = uid as? NSNumber
            return user
        }
    }
    
    func upDateGroupInfo(dic : [String : AnyObject]){
        createtime = dic["createtime"] as? NSNumber
        nickname = dic["nickname"] as? String
    }

}
