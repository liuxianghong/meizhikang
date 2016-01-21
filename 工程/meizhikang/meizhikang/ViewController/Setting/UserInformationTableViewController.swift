//
//  UserInformationTableViewController.swift
//  meizhikang
//
//  Created by 刘向宏 on 15/11/29.
//  Copyright © 2015年 刘向宏. All rights reserved.
//

import UIKit
import MBProgressHUD

class UserInformationTableViewController: UITableViewController {

    
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

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        let userInfo = NSUserDefaults.standardUserDefaults().objectForKey("userInfo") as! NSDictionary
        if let nickname = userInfo["nickname"] as? String , let weight = userInfo["weight"] as? Int, let height = userInfo["height"] as? Int,let old = userInfo["old"] as? Int,let sex = userInfo["sex"] as? Int{
            nickNameTextField.text = nickname
            wightTextField.text = "\(weight)"
            heightTextField.text = "\(height)"
            ageTextField.text = "\(old)"
            self.sexManButton.selected = sex == 0
            self.sexWomanButton.selected = sex != 0
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func okClick(sender : AnyObject) {
        let hud = MBProgressHUD.showHUDAddedTo(self.view.window, animated: true)
        
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
        
        let userInfo = NSUserDefaults.standardUserDefaults().objectForKey("userInfo") as! NSDictionary
        
        //let dic : NSDictionary = ["type":"modify_account","uid ":userInfo["uid"]!,"nickname":"234","height":175,"weight":650.5,"old":19,"sex":1]
        let dic : NSDictionary = ["type":"modify_account","uid ":userInfo["uid"]!,"nickname":self.nickNameTextField.text!,"height": Int(self.heightTextField.text!)!,"weight":Int(self.wightTextField.text!)!,"old":Int(self.ageTextField.text!)!,"sex": self.sexManButton.selected ? 0 : 1]
        
        IMRequst.RequstUserInfo(dic as [NSObject : AnyObject], completion: { (object) -> Void in
            print(object)
            let flag = object["flag"] as! Int
            if flag == 1{
                hud.detailsLabelText = "修改成功"
                self.navigationController?.popViewControllerAnimated(true)
            }
            else{
                hud.detailsLabelText = "修改失败"
            }
            hud.mode = .Text
            hud.hide(true, afterDelay: 1.5)
            
            }, failure: { (error : NSError!) -> Void in
                hud.mode = .Text
                hud.detailsLabelText = error.domain;
                hud.hide(true, afterDelay: 1.5)
                print(error)
        })
        
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
