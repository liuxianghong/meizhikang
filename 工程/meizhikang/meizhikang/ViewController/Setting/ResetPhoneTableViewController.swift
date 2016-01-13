//
//  ResetPhoneTableViewController.swift
//  meizhikang
//
//  Created by 刘向宏 on 15/11/29.
//  Copyright © 2015年 刘向宏. All rights reserved.
//

import UIKit
import MBProgressHUD

class ResetPhoneTableViewController: UITableViewController {

    @IBOutlet weak var nickNameTextField : UITextField!
    @IBOutlet weak var pwTextField : UITextField!
    @IBOutlet weak var stepLabel : UILabel!
    @IBOutlet weak var okButton : UIButton!
    var step = 1
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
        if step == 1{
            
            let hud = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
            if !self.nickNameTextField.text!.checkTel(){
                hud.mode = .Text
                hud.detailsLabelText = "请输入正确的手机号码"
                hud.hide(true, afterDelay: 1.5)
                return;
            }
            
            if self.pwTextField.text!.isEmpty{
                hud.mode = .Text
                hud.detailsLabelText = "请输入密码"
                hud.hide(true, afterDelay: 1.5)
                return;
            }
            
            let dic = ["type":"modify_tele","psd": pwTextField.text!.getBCDPassWord(),"phone":self.nickNameTextField.text!]
            
            IMRequst.RequstUserInfo(dic, completion: { (object) -> Void in
                print(object)
                let flag = object["flag"] as! Int
                if flag == 1{
                    self.step = 2
                    self.tableView.reloadData()
                    self.okButton.setTitle("确定", forState: .Normal)
                    self.stepLabel.text = "第二步"
                    self.nickNameTextField.placeholder = "请输入收到的验证码"
                    self.nickNameTextField.text = ""
                    self.nickNameTextField.keyboardType = .NumberPad
                    hud.hide(true)
                }
                else{
                    hud.detailsLabelText = "失败"
                    hud.mode = .Text
                    hud.hide(true, afterDelay: 1.5)
                }
                
                
                }, failure: { (error : NSError!) -> Void in
                    hud.mode = .Text
                    hud.detailsLabelText = error.domain;
                    hud.hide(true, afterDelay: 1.5)
                    print(error)
            })
            
            
        }
        else if step == 2{
            
            let hud = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
            
            if self.nickNameTextField.text!.isEmpty{
                hud.mode = .Text
                hud.detailsLabelText = "请输入验证码"
                hud.hide(true, afterDelay: 1.5)
                return;
            }
            
            let dic = ["type":"modify_phone","code": nickNameTextField.text!]
            
           IMRequst.RequstUserInfo(dic, completion: { (object) -> Void in
                print(object)
                let flag = object["flag"] as! Int
                if flag == 1{
                    
                    hud.detailsLabelText = "修改成功"
                    self.navigationController?.popViewControllerAnimated(true)
                    hud.mode = .Text
                    hud.hide(true, afterDelay: 1.5)
                }
                else{
                    hud.detailsLabelText = "验证码错误"
                    hud.mode = .Text
                    hud.hide(true, afterDelay: 1.5)
                }
                
                
                }, failure: { (error : NSError!) -> Void in
                    hud.mode = .Text
                    hud.detailsLabelText = error.domain;
                    hud.hide(true, afterDelay: 1.5)
                    print(error)
            })
        }
    }
    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 2
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if section == 0{
            return step==1 ? 5 : 3
        }
        return 1
    }

    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.section == 0{
            if indexPath.row == 0 || indexPath.row == 4{
                return 45
            }
            else
            {
                return 60;
            }
        }
        else
        {
            let rowNumber:CGFloat = step==1 ? (60.0*3.0+45*2.0) : (60.0*2.0+45)
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
