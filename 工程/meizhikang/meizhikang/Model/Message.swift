//
//  Message.swift
//  meizhikang
//
//  Created by shadowPriest on 15/12/20.
//  Copyright © 2015年 刘向宏. All rights reserved.
//

import Foundation
import CoreData

enum MessageType {
    case Text
    case Voice
    case Image
    case Picture
    case UnKnow
}

class Message: NSManagedObject {

// Insert code here to add functionality to your managed object subclass

    func upDateMessageInfo(dic : [String : AnyObject]){
        fromid = dic["fromid"] as? NSNumber
        sendtime = dic["sendtime"] as? NSNumber
        gid = dic["gid"] as? NSNumber
        uuid = dic["uuid"] as? NSNumber
        pushtype = dic["pushtype"] as? String
        content = dic["content"] as? String
        
        if messageType() == .Image{
            let string = content! as NSString
            let array = string.componentsSeparatedByString("[/image][key]")
            var imageUrl = array[0]
            var keyString = array[1]
            imageUrl = imageUrl.stringByReplacingOccurrencesOfString("[image]", withString: "")
            keyString = keyString.stringByReplacingOccurrencesOfString("[/key]", withString: "")
            //let urlMD5 = imageUrl.dataFromMD5().description.formatData()
            
            let imagedata = NSData(contentsOfURL: NSURL(string: imageUrl)!)
            let dataKey = keyString.dataFromHexString()
            print(dataKey)
            let ddata = NSString.decryptWithAES(imagedata, withKey: dataKey.bytes)
            if ddata.length > 16{
                data = NSData(bytes: ddata.bytes+16, length: ddata.length-16)
//                if filedata.writeToFile(path!, atomically: false){
//                    filepath = path
//                }
//                else
//                {
//                    data = filedata
//                }
            }
            
//            let path = getImageFilePath(urlMD5)
//            if !NSFileManager.defaultManager().fileExistsAtPath(path!){
//                
//            }
//            else{
//                filepath = path
//            }
        }
        else if messageType() == .Voice{
            
            let string = content! as NSString
            let array = string.componentsSeparatedByString("[/url][key]")
            var imageUrl = array[0]
            var keyString = array[1]
            imageUrl = imageUrl.stringByReplacingOccurrencesOfString("[url]", withString: "")
            keyString = keyString.stringByReplacingOccurrencesOfString("[/key]", withString: "")
            let imagedata = NSData(contentsOfURL: NSURL(string: imageUrl)!)
            let dataKey = keyString.dataFromHexString()
            print(dataKey)
            let ddata = NSString.decryptWithAES(imagedata, withKey: dataKey.bytes)
            if ddata.length > 16{
                data = NSData(bytes: ddata.bytes+16, length: ddata.length-16)
            }
            
        }
        
        dispatch_async(dispatch_get_main_queue()){
            if self.gid?.integerValue != 0 {
                let g = UserInfo.CurrentUser()!.groupByID(self.gid!)! as Group
                g.mutableSetValueForKey("messages").addObject(self)
            }
        }
    }
    
    func text() -> String{
        var text = content!.stringByReplacingOccurrencesOfString("[text]", withString: "")
        text = text.stringByReplacingOccurrencesOfString("[/text]", withString: "")
        return text
    }
    
    func image() -> UIImage?{
        if (data != nil){
            if let image = UIImage(data: data!){
                return image
            }
        }
        return UIImage(named: "框")
    }
    
    func Data() -> NSData?{
        return data
    }
    
    func saveData(dataFile : NSData){
        data = dataFile
    }
    
    
    func messageType() ->MessageType{
        if content!.hasPrefix("[text]"){
            return .Text
        }
        else if content!.hasPrefix("[url]"){
            return .Voice
        }
        else if content!.hasPrefix("[image]"){
            return .Image
        }
        else if content!.hasPrefix("[picture]"){
            return .Picture
        }
        return .UnKnow
    }
    
    func getImageFilePath(name : String) -> String?{
        let path = "\(NSHomeDirectory())/Documents/\(name)"
        return path
    }
}
