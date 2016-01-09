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
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "login:", name: "loginOutNotification", object: nil)
        BLEConnect.Instance().startScan()
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
    
    func login(object : AnyObject?){
        print(object)
        if let notification = object as? NSNotification{
            if let message = notification.object as? String{
                
                let actionVC = UIAlertController(title: "提示", message: message, preferredStyle: .Alert)
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
                    self.performSegueWithIdentifier("loginIdentifier", sender: nil)
                })
                
                actionVC.addAction(actionlogin)
                actionVC.addAction(actionCancel)
                
                self.presentViewController(actionVC, animated: true, completion: { () -> Void in
                    
                })
            }
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
            NSNotificationCenter.defaultCenter().postNotificationName("didLogoutNotification", object: nil)
        }
    }


}
