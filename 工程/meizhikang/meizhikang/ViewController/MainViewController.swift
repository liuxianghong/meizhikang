//
//  MainViewController.swift
//  meizhikang
//
//  Created by 刘向宏 on 15/11/29.
//  Copyright © 2015年 刘向宏. All rights reserved.
//

import UIKit
import MBProgressHUD

class MainViewController: UINavigationController {

    var first : Bool = true
    var timer : NSTimer!
    var timerCount =  60
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "login:", name: "loginOutNotification", object: nil)
        
        NSNotificationCenter.defaultCenter().addObserverForName("RingSwichOnNotification", object: nil, queue: NSOperationQueue.mainQueue()) { (notification : NSNotification) -> Void in
            
            if UserInfo.ringing{
                return
            }
            self.timerCount = 61
            self.timer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector:"cutDown" , userInfo: nil, repeats: true)
            self.cutDown()
            self.performSegueWithIdentifier("RingIdenfier", sender: nil)
        }
        
        NSNotificationCenter.defaultCenter().addObserverForName("reciveIMPushNotification", object: nil, queue: NSOperationQueue.mainQueue()) { (notification : NSNotification) -> Void in
            let joson = JSON(notification.object!)
            if joson != nil{
                let pushtype = joson["pushtype"].stringValue
                if pushtype == "meet"{
                    let message = Message.MessageByUuid(joson["uuid"].numberValue)
                    if message?.messageType() == .UnKnow{
                        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
                            message?.upDateMessageInfo(joson.dictionaryObject!)
                        });
                    }
                }
                else if pushtype == "email"{
                    let email = Email.EmailByUuid(joson["uuid"].numberValue)
                    email?.upDateEmailInfo(joson.dictionaryObject!)
                    NSManagedObjectContext.MR_defaultContext().MR_saveToPersistentStoreAndWait()
                    NSNotificationCenter.defaultCenter().postNotificationName("reciveEmailNotification", object: nil)
                }
                else if pushtype == "group_change"{
                    UserInfo.CurrentUser()?.loadGrous()
                }
                else{
                    NSLog("unknow pushtype");
                }
            }
            
        }
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }

    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        if first{
            first = false
            self.performSegueWithIdentifier("loginIdentifier", sender: nil)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
    
    func cutDown(){
        timerCount--
        if timerCount == 0{
            self.timer.invalidate()
            self.timer = nil
        }
    }
    
    
    func login(object : AnyObject?){
        print(object)
        if let notification = object as? NSNotification{
            var messageStr = "您已离线"
            if let message = notification.object as? String{
                messageStr = message
            }
            let actionVC = UIAlertController(title: "提示", message: messageStr, preferredStyle: .Alert)
            let actionlogin = UIAlertAction(title: "重新登录", style: .Default, handler: { (ac :UIAlertAction) -> Void in
                
                let hud = MBProgressHUD.showHUDAddedTo(self.view.window, animated: true)
                hud.detailsLabelText = "正在重新登录";
                IMRequst.LoginWithUserName(UserInfo.CurrentUser()?.userName, passWord: UserInfo.CurrentUser()?.passWord, completion: { (ip : UInt32,port : UInt16) -> Void in
                    print(ip,port)
                    hud.hide(true)
                    }) { (error : NSError!) -> Void in
                        IMRequst.LoginOut(false)
                        hud.mode = .Text
                        hud.detailsLabelText = error.domain;
                        hud.hide(true, afterDelay: 1.5)
                        print(error)
                        self.performSegueWithIdentifier("loginIdentifier", sender: nil)
                }
                
                
            })
            let actionCancel = UIAlertAction(title: "退出", style: .Cancel, handler: { (UIAlertAction) -> Void in
                self.performSegueWithIdentifier("loginIdentifier", sender: false)
            })
            
            actionVC.addAction(actionlogin)
            actionVC.addAction(actionCancel)
            
            self.presentViewController(actionVC, animated: true, completion: { () -> Void in
                
            })
        }
        
    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "loginIdentifier"{
            NSUserDefaults.standardUserDefaults().setObject(nil, forKey: "userInfo")
            NSUserDefaults.standardUserDefaults().synchronize()
            if let bo = sender as? Bool{
                UserInfo.autoLogin = bo
            }
            NSNotificationCenter.defaultCenter().postNotificationName("didLogoutNotification", object: nil)
        }
    }


}
