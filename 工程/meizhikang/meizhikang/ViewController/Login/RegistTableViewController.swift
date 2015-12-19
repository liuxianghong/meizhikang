//
//  RegistTableViewController.swift
//  meizhikang
//
//  Created by 刘向宏 on 15/11/29.
//  Copyright © 2015年 刘向宏. All rights reserved.
//

import UIKit
import MBProgressHUD

class RegistTableViewController: UITableViewController {

    @IBOutlet weak var userNameTextField : UITextField!
    @IBOutlet weak var passWordTextField : UITextField!
    @IBOutlet weak var nickNameTextField : UITextField!
    @IBOutlet weak var wightTextField : UITextField!
    @IBOutlet weak var heightTextField : UITextField!
    @IBOutlet weak var ageTextField : UITextField!
    @IBOutlet weak var sexManButton : UIButton!
    @IBOutlet weak var sexWomanButton : UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func registClick(sender : AnyObject) {
        
        let hud = MBProgressHUD.showHUDAddedTo(self.view.window, animated: true)
        if !self.userNameTextField.text!.checkTel(){
            hud.mode = .Text
            hud.detailsLabelText = "请输入正确的手机号"
            hud.hide(true, afterDelay: 1.5)
            return;
        }
        if self.passWordTextField.text!.isEmpty{
            hud.mode = .Text
            hud.detailsLabelText = "请输入密码"
            hud.hide(true, afterDelay: 1.5)
            return;
        }
        
        if self.passWordTextField.text!.lengthOfBytesUsingEncoding(NSUTF8StringEncoding)>16{
            hud.mode = .Text
            hud.detailsLabelText = "密码长度最大16个字符"
            hud.hide(true, afterDelay: 1.5)
            return;
        }
        
        if self.nickNameTextField.text!.isEmpty{
            hud.mode = .Text
            hud.detailsLabelText = "请输入昵称"
            hud.hide(true, afterDelay: 1.5)
            return;
        }
        
        if self.nickNameTextField.text!.lengthOfBytesUsingEncoding(NSUTF8StringEncoding)>16{
            hud.mode = .Text
            hud.detailsLabelText = "昵称长度最大16个字符"
            hud.hide(true, afterDelay: 1.5)
            return;
        }
        
        if self.wightTextField.text!.isEmpty{
            hud.mode = .Text
            hud.detailsLabelText = "请输入体重"
            hud.hide(true, afterDelay: 1.5)
            return;
        }
        
        let wight = UInt16(self.wightTextField.text!)
        if wight<30 || wight>200{
            hud.mode = .Text
            hud.detailsLabelText = "体重应该在30kg-200kg"
            hud.hide(true, afterDelay: 1.5)
            return;
        }
        
        
        if self.heightTextField.text!.isEmpty{
            hud.mode = .Text
            hud.detailsLabelText = "请输入身高"
            hud.hide(true, afterDelay: 1.5)
            return;
        }
        
        let height = UInt8(self.heightTextField.text!)
        if height<70 || height>250{
            hud.mode = .Text
            hud.detailsLabelText = "身高应该在70cm-250cm"
            hud.hide(true, afterDelay: 1.5)
            return;
        }
        
        if self.ageTextField.text!.isEmpty{
            hud.mode = .Text
            hud.detailsLabelText = "请输入年龄"
            hud.hide(true, afterDelay: 1.5)
            return;
        }
        
        let age = UInt8(self.ageTextField.text!)
        if age<5 || age>100{
            hud.mode = .Text
            hud.detailsLabelText = "年龄应该在5岁-100岁"
            hud.hide(true, afterDelay: 1.5)
            return;
        }
        
        let sex : UInt8 = self.sexManButton.selected ? 1 : 0
        
        IMConnect.Instance().getRegistToken(self.userNameTextField.text, completion: { (token : NSData!, data : NSData!) -> Void in
            print(token)
            IMConnect.Instance().registWithToken(token, withCode: "1234", withNickName: self.nickNameTextField.text, withPW: "123456", withSex: sex, withAge: age!, withHeiht: height!, withWight: wight!, completion: { () -> Void in
                //hud.mode = .Text
                hud.detailsLabelText = "注册成功，正在获取用户信息";
                let dic : NSDictionary = ["type": "account"]
                IMConnect.Instance().RequstUserInfo(dic as [NSObject : AnyObject], completion: { (object) -> Void in
                    print(object)
                    NSUserDefaults.standardUserDefaults().setObject(object, forKey: "userInfo")
                    NSUserDefaults.standardUserDefaults().synchronize()
                    self.dismissViewControllerAnimated(true) { () -> Void in
                    }
                    hud.hide(true)
                    
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
    
    @IBAction func sexManClick(sender : UIButton) {
        sender.selected = true;
        self.sexWomanButton.selected = false;
    }
    
    
    @IBAction func sexWomenClick(sender : UIButton) {
        sender.selected = true;
        self.sexManButton.selected = false;
    }
    // MARK: - Table view data source

//    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
//        // #warning Incomplete implementation, return the number of sections
//        return 0
//    }
//
//    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        // #warning Incomplete implementation, return the number of rows
//        return 0
//    }

    /*
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("reuseIdentifier", forIndexPath: indexPath)

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
