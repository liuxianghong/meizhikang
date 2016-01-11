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

class LoginViewController: UIViewController,UITextFieldDelegate {

    @IBOutlet weak var userNameTextField : UITextField!
    @IBOutlet weak var passWordTextField : UITextField!
    var first : Bool = true
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        #if DEBUG
        self.userNameTextField.text = "12345671"
        self.passWordTextField.text = "111111"
        #endif
        
        self.userNameTextField.delegate = self
        self.passWordTextField.delegate = self
        
        if UserInfo.LastLoginUser() != nil{
            self.userNameTextField.text = UserInfo.LastLoginUser()?.userName
            self.passWordTextField.text = UserInfo.LastLoginUser()?.passWord
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if !first{
            IMRequst.LoginOut(false)
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        if first && UserInfo.autoLogin{
            first = false
            if !self.passWordTextField.text!.isEmpty{
                loginClick(1)
            }
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        UserInfo.autoLogin = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
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
        IMRequst.LoginWithUserName(self.userNameTextField.text, passWord: self.passWordTextField.text, completion: { (ip : UInt32,port : UInt16) -> Void in
            print(ip,port)
            hud.detailsLabelText = "登录成功，正在获取用户信息";
            IMRequst.GetUserInfoCompletion({ (object) -> Void in
                hud.hide(true)
                print(object)
                NSUserDefaults.standardUserDefaults().setObject(object, forKey: "userInfo")
                NSUserDefaults.standardUserDefaults().setObject(object["uid"], forKey: "LastUserID")
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
                    IMRequst.LoginOut(false)
                    print(error)
            })
            }) { (error : NSError!) -> Void in
                IMRequst.LoginOut(false)
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
