//
//  Email.swift
//  meizhikang
//
//  Created by 刘向宏 on 15/12/20.
//  Copyright © 2015年 刘向宏. All rights reserved.
//

import Foundation
import CoreData

enum EmailType {
    case Invite
    case Apply
    case UnKnow
}

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
        if emailType() == .Apply{
            var str = content! as NSString
            str = str.stringByReplacingOccurrencesOfString("[apply]", withString: "")
            str = str.stringByReplacingOccurrencesOfString("[/apply]", withString: "")
            let array = str.componentsSeparatedByString(",")
            if array.count == 2{
                gid = Int(array[0])
                uid = Int(array[1])
            }
            
        }
        else if emailType() == .Invite{
            var str = content! as NSString
            str = str.stringByReplacingOccurrencesOfString("[invite]", withString: "")
            str = str.stringByReplacingOccurrencesOfString("[/invite]", withString: "")
            gid = str.integerValue
            print(gid)
        }
    }

    func emailType() ->EmailType{
        if content == nil{
            return .UnKnow
        }
        if content!.hasPrefix("[invite]"){
            return .Invite
        }
        else if content!.hasPrefix("[apply]"){
            return .Apply
        }
        return .UnKnow
    }
}
