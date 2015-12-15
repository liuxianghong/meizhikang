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
        guard let userInfo = NSUserDefaults.standardUserDefaults().objectForKey("userInfo") as? [String : AnyObject],
            let uid = userInfo["uid"] as? Int
        else{
            return nil
        }
        return String(uid)
    }
    static func nickname()->String?{
        guard let userInfo = NSUserDefaults.standardUserDefaults().objectForKey("userInfo") as? [String : AnyObject] else{
            return nil
        }
        return userInfo["nickname"] as? String
    }

}
