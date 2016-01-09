//
//  UserInfo.swift
//  meizhikang
//
//  Created by shadowPriest on 15/12/15.
//  Copyright © 2015年 刘向宏. All rights reserved.
//

import UIKit

class UserInfo: NSObject {
    static func uid()->String?{
        if let userInfo = NSUserDefaults.standardUserDefaults().objectForKey("userInfo") as? [String : AnyObject],let uid = userInfo["uid"] as? Int{
            return String(uid)
        }
        else{
            return nil
        }
    }
    static func nickname()->String?{
        if let userInfo = NSUserDefaults.standardUserDefaults().objectForKey("userInfo") as? [String : AnyObject] {
            return userInfo["nickname"] as? String
        }else{
            return nil
        }
    }

    static func CurrentUser()->User?{
        
        if let userInfo = NSUserDefaults.standardUserDefaults().objectForKey("userInfo") as? [String : AnyObject],let uid = userInfo["uid"] as? Int{
            return User.userByUid(uid)
        }
        else{
            return nil
        }
    }
    
    static func LastLoginUser()->User?{
        
        if let uid = NSUserDefaults.standardUserDefaults().objectForKey("LastUserID") as? Int{
            return User.userByUid(uid)
        }
        else{
            return nil
        }
    }
}
