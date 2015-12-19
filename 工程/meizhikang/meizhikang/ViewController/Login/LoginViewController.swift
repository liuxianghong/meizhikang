//
//  LoginViewController.swift
//  meizhikang
//
//  Created by 刘向宏 on 15/11/29.
//  Copyright © 2015年 刘向宏. All rights reserved.
//

import UIKit
import MBProgressHUD
import MagicalRecord

class LoginViewController: UIViewController {

    @IBOutlet weak var userNameTextField : UITextField!
    @IBOutlet weak var passWordTextField : UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.userNameTextField.text = "12345671"
        self.passWordTextField.text = "123456"
        
        //IMConnect.Instance().test()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func registLaterClick(sender : AnyObject) {
        self.dismissViewControllerAnimated(true) { () -> Void in
            
        }
    }
    
    @IBAction func loginClick(sender : AnyObject) {
        
        let hud = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        if self.userNameTextField.text!.isEmpty{
            hud.mode = .Text
            hud.detailsLabelText = "请输入用户名"
            hud.hide(true, afterDelay: 1.5)
            return;
        }
        if self.passWordTextField.text!.isEmpty{
            hud.mode = .Text
            hud.detailsLabelText = "请输入密码"
            hud.hide(true, afterDelay: 1.5)
            return;
        }
        
        hud.detailsLabelText = "正在登录";
        IMConnect.Instance().getToken(self.userNameTextField.text, completion: { (token : NSData!, data : NSData!) -> Void in
            print(token)
            IMConnect.Instance().login(self.passWordTextField.text, withToken: token, completion: { (ip : UInt32,port : UInt16) -> Void in
                print(ip,port)
                hud.detailsLabelText = "登录成功，正在获取用户信息";
                let dic : NSDictionary = ["type": "account"]
                IMConnect.Instance().RequstUserInfo(dic as [NSObject : AnyObject], completion: { (object) -> Void in
                    hud.hide(true)
                    print(object)
                    NSUserDefaults.standardUserDefaults().setObject(object, forKey: "userInfo")
                    NSUserDefaults.standardUserDefaults().synchronize()
                    let user = User.userByUid(object["uid"]!!)
                    user!.upDateUserInfo(object as! [String : AnyObject])
                    user!.userName = self.userNameTextField.text
                    user!.passWord = self.passWordTextField.text
                    NSManagedObjectContext.MR_defaultContext().MR_saveToPersistentStoreAndWait()
                    
                    self.dismissViewControllerAnimated(true) { () -> Void in
                    }
                    }, failure: { (error : NSError!) -> Void in
                        hud.mode = .Text
                        hud.detailsLabelText = error.domain;
                        hud.hide(true, afterDelay: 1.5)
                        print(error)
                })
                
                }, failure: { (error : NSError!) -> Void in
                    hud.mode = .Text
                    hud.detailsLabelText = error.domain;
                    hud.hide(true, afterDelay: 1.5)
                    print(error)
            })
            
            }) { (error : NSError!) -> Void in
                hud.mode = .Text
                hud.detailsLabelText = error.domain;
                hud.hide(true, afterDelay: 1.5)
                print(error)
        }
        
    }
    
    @IBAction func pinGesClick(sender : AnyObject) {
        self.userNameTextField.resignFirstResponder()
        self.passWordTextField.resignFirstResponder()
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
