//
//  Email.swift
//  meizhikang
//
//  Created by 刘向宏 on 15/12/20.
//  Copyright © 2015年 刘向宏. All rights reserved.
//

import Foundation
import CoreData


class Email: NSManagedObject {

// Insert code here to add functionality to your managed object subclass
    static func EmailByUuid(uuid : AnyObject) -> Email?{
        
        if let email = Email.MR_findByAttribute("uuid", withValue: uuid).first as? Email{
            return email;
        }
        else{
            let email = Email.MR_createEntity()
            email.uuid = uuid as? NSNumber
            return email
        }
    }
    
    func upDateEmailInfo(dic : [String : AnyObject]){
        fromid = dic["fromid"] as? NSNumber
        sendtime = dic["sendtime"] as? NSNumber
        title = dic["title"] as? String
        content = dic["content"] as? String
        user = UserInfo.CurrentUser()
    }

}
