//
//  SwitchAccountTableViewController.swift
//  meizhikang
//
//  Created by 刘向宏 on 15/11/30.
//  Copyright © 2015年 刘向宏. All rights reserved.
//

import UIKit
import MBProgressHUD

class SwitchAccountTableViewController: UITableViewController {

    var tableViewArray = [User]()
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        tableViewArray = User.MR_findAll() as! [User]
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func login(user : User){
        let hud = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        
        hud.detailsLabelText = "正在登录";
        IMRequst.LoginWithUserName(user.userName, passWord: user.passWord, completion: { (ip : UInt32,port : UInt16) -> Void in
            print(ip,port)
            hud.detailsLabelText = "登录成功，正在获取用户信息";
            IMRequst.GetUserInfoCompletion({ (object) -> Void in
                print(object)
                NSUserDefaults.standardUserDefaults().setObject(object, forKey: "userInfo")
                NSUserDefaults.standardUserDefaults().setObject(object["uid"], forKey: "LastUserID")
                NSUserDefaults.standardUserDefaults().synchronize()
                let user = User.userByUid(object["uid"]!!)
                user!.upDateUserInfo(object as! [String : AnyObject])
                NSManagedObjectContext.MR_defaultContext().MR_saveToPersistentStoreAndWait()
                hud.hide(true)
                self.tableView.reloadData()
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

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return tableViewArray.count
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        if UserInfo.CurrentUser()?.uid != tableViewArray[indexPath.row].uid{
            login(tableViewArray[indexPath.row])
        }
    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30;
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return ""
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell:SettingTableViewCell = tableView.dequeueReusableCellWithIdentifier("settingIndentifer", forIndexPath: indexPath) as! SettingTableViewCell
        
        // Configure the cell...
        cell.titleLabel.text = tableViewArray[indexPath.row].userName
        cell.stateImageView.hidden = !(UserInfo.CurrentUser()?.uid == tableViewArray[indexPath.row].uid)
        return cell
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
