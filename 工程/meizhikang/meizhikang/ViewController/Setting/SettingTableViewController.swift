//
//  SettingTableViewController.swift
//  meizhikang
//
//  Created by 刘向宏 on 15/11/29.
//  Copyright © 2015年 刘向宏. All rights reserved.
//

import UIKit

class SettingTableViewController: UITableViewController,AlartViewControllerDelegate {

    var tableViewArray : NSArray = [["个人","个人资料","修改密码"],["告警","告警设置","告警演示"],["系统","蓝牙连接","关于","注销","退出"]]
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

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return tableViewArray.count
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return tableViewArray[section].count - 1
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        if indexPath.section == 0 {
            if indexPath.row == 0{
                self.performSegueWithIdentifier("myinformationIdentifier", sender: nil)
            }
//            else if indexPath.row == 1{
//                self.performSegueWithIdentifier("resetPhone", sender: nil)
//            }
            else if indexPath.row == 1{
                self.performSegueWithIdentifier("modifPWIdentifier", sender: nil)
            }
        }
        else if indexPath.section == 1{
            if indexPath.row == 0{
                self.performSegueWithIdentifier("alarmIdentifier", sender: nil)
            }
            else if indexPath.row == 1{
                self.performSegueWithIdentifier("alarm2Identifier", sender: nil)
            }
        }
        else if indexPath.section == 2{
            if indexPath.row == 0{
                self.performSegueWithIdentifier("bleIdentifier", sender: nil)
            }
//            else if indexPath.row == 1{
//                self.performSegueWithIdentifier("SwitchAccountIdentifier", sender: nil)
//            }
//            else if indexPath.row == 2{
//                self.performSegueWithIdentifier("SwitchoverIdentifier", sender: nil)
//            }
            else if indexPath.row == 1{
                self.performSegueWithIdentifier("aboutIndentifier", sender: nil)
            }
            else if indexPath.row == 2{
                self.performSegueWithIdentifier("alertIndentifier", sender: 0)
            }
            else if indexPath.row == 3{
                self.performSegueWithIdentifier("alertIndentifier", sender: 1)
            }
        }
        
    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30;
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let array:NSArray = tableViewArray[section] as! NSArray
        return array[0] as? String
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell:SettingTableViewCell = tableView.dequeueReusableCellWithIdentifier("settingIndentifer", forIndexPath: indexPath) as! SettingTableViewCell

        // Configure the cell...
        let array:NSArray = tableViewArray[indexPath.section] as! NSArray
        cell.titleLabel.text = array[indexPath.row+1] as? String

        return cell
    }
    // MARK: - Alert
    func didClickButton(index: Int, tag: Int) {
        if index == 1{
            if tag == 1{
                exit(0)
            }
            else
            {
                if self.revealViewController() != nil{
                    IMRequst.LoginOut(false)
                    UserInfo.CurrentUser()?.passWord = nil
                    NSManagedObjectContext.MR_defaultContext().MR_saveToPersistentStoreAndWait()
                    self.revealViewController().navigationController!.performSegueWithIdentifier("loginIdentifier", sender: nil)
                }
            }
        }
    }


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

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        if self.revealViewController() != nil{
            self.revealViewController().setFrontViewPosition(.Left, animated: true)
        }
        
        if segue.identifier == "alertIndentifier"{
            let vc:AlertViewController = segue.destinationViewController as! AlertViewController
            vc.tag = sender as! Int
            if(vc.tag==0){
                vc.titleText = "注销"
                vc.messageText = "确定要注销吗？"
            }
            else
            {
                vc.titleText = "退出"
                vc.messageText = "确定要退出吗？"
            }
            vc.delegate = self
        }
        
    }
    

}
