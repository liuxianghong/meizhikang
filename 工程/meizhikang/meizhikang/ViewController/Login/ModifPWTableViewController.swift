//
//  ModifPWTableViewController.swift
//  meizhikang
//
//  Created by 刘向宏 on 15/11/29.
//  Copyright © 2015年 刘向宏. All rights reserved.
//

import UIKit
import MBProgressHUD

class ModifPWTableViewController: UITableViewController {

    @IBOutlet weak var odlpwTextField : UITextField!
    @IBOutlet weak var newpwTextField : UITextField!
    @IBOutlet weak var renewpwTextField : UITextField!
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

    @IBAction func okClick(sender : AnyObject) {
        
        let hud = MBProgressHUD.showHUDAddedTo(self.view.window, animated: true)
        if self.odlpwTextField.text!.isEmpty{
            hud.mode = .Text
            hud.detailsLabelText = "请输入旧密码"
            hud.hide(true, afterDelay: 1.5)
            return;
        }
        if self.newpwTextField.text!.isEmpty{
            hud.mode = .Text
            hud.detailsLabelText = "请输入新密码"
            hud.hide(true, afterDelay: 1.5)
            return;
        }
        
        if self.newpwTextField.text!.lengthOfBytesUsingEncoding(NSUTF8StringEncoding) < 6{
            hud.mode = .Text
            hud.detailsLabelText = "密码不能少于6位"
            hud.hide(true, afterDelay: 1.5)
            return;
        }
        
        if self.renewpwTextField.text!.isEmpty{
            hud.mode = .Text
            hud.detailsLabelText = "请确认新密码"
            hud.hide(true, afterDelay: 1.5)
            return;
        }
        
        if self.renewpwTextField.text != self.newpwTextField.text{
            hud.mode = .Text
            hud.detailsLabelText = "新密码错误"
            hud.hide(true, afterDelay: 1.5)
            return;
        }
        let dic = ["type":"modify_psd","oldpsd": odlpwTextField.text!.getBCDPassWord() ,"newpsd":newpwTextField.text!.getBCDPassWord()]
        
        IMRequst.RequstUserInfo(dic, completion: { (object) -> Void in
            print(object)
            let flag = object["flag"] as! Int
            if flag == 1{
                hud.detailsLabelText = "修改成功,请重新登录"
                
                //IMRequst.LoginOut(true)
                UserInfo.CurrentUser()?.passWord = nil
                NSUserDefaults.standardUserDefaults().setObject(nil, forKey: "userInfo")
                NSManagedObjectContext.MR_defaultContext().MR_saveToPersistentStoreAndWait()
                self.revealViewController().navigationController!.performSegueWithIdentifier("loginIdentifier", sender: nil)
                //self.navigationController?.popViewControllerAnimated(true)
            }
            else if flag == -1{
                hud.detailsLabelText = "原密码不正确"
            }
            else if flag == -2{
                hud.detailsLabelText = "修改过于频繁"
            }
            else{
                hud.detailsLabelText = "失败，其他错误"
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

    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.section == 0{
            if indexPath.row == 0{
                return 45
            }
            else
            {
                return 60;
            }
        }
        else
        {
            let rowNumber:CGFloat = (60.0*3.0+45*1.0)
            return self.tableView.frame.size.height - rowNumber - 80
        }
    }
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
