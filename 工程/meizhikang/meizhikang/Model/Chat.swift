//
//  Chat.swift
//  meizhikang
//
//  Created by 刘向宏 on 16/1/12.
//  Copyright © 2016年 刘向宏. All rights reserved.
//

import Foundation
import CoreData


class Chat: NSManagedObject {

// Insert code here to add functionality to your managed object subclass

    static func ChatByGroupMember(member : GroupMember ,user : User) -> Chat?{
        
        let predicateTemplate = NSPredicate(format: "member =  %@ AND user = %@", member,user)
        if let chat = Chat.MR_findFirstWithPredicate(predicateTemplate){
            return chat;
        }
        else{
            let chat = Chat.MR_createEntity()
            chat.member = member
            chat.user = user
            return chat
        }
    }
}
