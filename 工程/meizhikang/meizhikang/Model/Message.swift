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

    static func MessageByUuid(uuid : AnyObject) -> Message?{
        
        if let message = Message.MR_findByAttribute("uuid", withValue: uuid).first as? Message{
            return message;
        }
        else{
            let message = Message.MR_createEntity()
            message.uuid = uuid as? NSNumber
            return message
        }
    }
    
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
                g.unRead = true
            }
            else{
                let m = GroupMember.GroupMemberByUid(self.fromid!)
                let chat = Chat.ChatByGroupMember(m!, user: UserInfo.CurrentUser()!)
                if chat?.unReadMessage == nil{
                    chat?.unReadMessage = 0
                }
                else{
                    chat?.unReadMessage = (chat!.unReadMessage?.integerValue)! + 1
                }
                self.chat = chat
            }
            NSManagedObjectContext.MR_defaultContext().MR_saveToPersistentStoreAndWait()
            NSNotificationCenter.defaultCenter().postNotificationName("reciveMessageNotification", object: self)
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
        if content == nil{
            return .UnKnow
        }
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
