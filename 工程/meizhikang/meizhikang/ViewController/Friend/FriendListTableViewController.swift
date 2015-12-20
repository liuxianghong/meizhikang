//
//  FriendListTableViewController.swift
//  meizhikang
//
//  Created by 刘向宏 on 15/11/28.
//  Copyright © 2015年 刘向宏. All rights reserved.
//

import UIKit
import MagicalRecord

struct FriendListTableViewControllerConstant{
    static let chatSegueIdentifier = "ChatSegueIdentifier"
}

class FriendListTableViewController: UITableViewController {

    @IBOutlet weak var typeImageView1 : UIImageView!
    @IBOutlet weak var typeImageView2 : UIImageView!
    @IBOutlet weak var typeImageView3 : UIImageView!
    var groupArray :Array<Group> = []
    var emailArray = [Email]()
    var type = 1
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        typeImageView2.hidden = true;
        typeImageView3.hidden = true;
        
        var frame = self.tableView.tableHeaderView?.frame
        frame?.size.height = 50.0
        self.tableView.tableHeaderView?.frame = frame!
        
        let dic = ["type":"get_email","page":1 ,"number":20]
        IMConnect.Instance().RequstUserInfo(dic, completion: { (object) -> Void in
            print(object)

            }) { (error : NSError!) -> Void in
                
        }

    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        let dic = ["type":"groups"]
        
        emailArray = Email.MR_findAll() as! [Email]
        
        IMConnect.Instance().RequstUserInfo(dic, completion: { (object) -> Void in
            print(object)
            let json = JSON(object)
            let groups = json["groups"].arrayValue
            self.groupArray.removeAll()
            for groupDic in groups{
                let dd = groupDic.dictionaryValue
                let group = Group.GroupByGid((dd["gid"]?.object)!)
                group?.upDateGroupInfo(groupDic.dictionaryObject!)
                let user = UserInfo.CurrentUser()
                if !(group!.user?.containsObject(user!))!{
                    let users = group!.mutableSetValueForKey("user")
                    users.addObject(user!)
                }
                self.groupArray.append(group!)
            }
            NSManagedObjectContext.MR_defaultContext().MR_saveToPersistentStoreAndWait()
            self.tableView.reloadData()
            
            }, failure: { (error : NSError!) -> Void in
        })
        
        self.tableView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func typeButtonClick(sender : UIButton){
        if type != sender.tag{
            type = sender.tag
            tableView.reloadData()
            typeImageView1.hidden = type != 1
            typeImageView2.hidden = type != 2
            typeImageView3.hidden = type != 3
        }
    }
    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if type == 1{
            return self.groupArray.count + 1
        }
        else if type == 3{
            return emailArray.count
        }
        return type+1
    }

    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if type==1 && (indexPath.section==0 && indexPath.row == 0){
            return 45
        }
        return 60
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if type==1 && (indexPath.section==0 && indexPath.row == 0){
            let cell = tableView.dequeueReusableCellWithIdentifier("addCellIdentifier", forIndexPath: indexPath)
            
            // Configure the cell...
            
            return cell
        }
        
        let cell:FriendTableViewCell = tableView.dequeueReusableCellWithIdentifier("friendCellIdentifier", forIndexPath: indexPath) as! FriendTableViewCell

        // Configure the cell...
        if type == 1{
            cell.typeImageView.image = UIImage(named: "通讯2")
            let group = self.groupArray[indexPath.row-1]
            cell.nameLabel.text = group.gname
        }
        else if type == 2{
            cell.typeImageView.image = UIImage(named: "联系人-蓝")
        }
        else if type == 3{
            let email = emailArray[indexPath.row]
            cell.typeImageView.image = UIImage(named: "记录-蓝")
            cell.nameLabel.text = email.title
        }
        cell.numberLabel.hidden = type != 1

        return cell
    }


    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        if type==1 && (indexPath.section==0 && indexPath.row == 0){
            let actionVC = UIAlertController(title: "", message: "加入或创建一个群", preferredStyle: .ActionSheet)
            let actionNew = UIAlertAction(title: "创建群", style: .Default, handler: { (UIAlertAction) -> Void in
                
            })
            
            let actionAdd = UIAlertAction(title: "加入群", style: .Default, handler: { (UIAlertAction) -> Void in
                
            })
            
            let actionCancel = UIAlertAction(title: "取消", style: .Cancel, handler: { (UIAlertAction) -> Void in
                
            })
            
            actionVC.addAction(actionNew)
            actionVC.addAction(actionAdd)
            actionVC.addAction(actionCancel)
            
            self.presentViewController(actionVC, animated: true, completion: { () -> Void in
                
            })
        }else{
            self.performSegueWithIdentifier(FriendListTableViewControllerConstant.chatSegueIdentifier, sender: indexPath)
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
        if segue.identifier == FriendListTableViewControllerConstant.chatSegueIdentifier{
            guard let vc = segue.destinationViewController as? ChatViewController,
                let sendId = UserInfo.uid(),
                let nickname = UserInfo.nickname(),
                let indexPath = sender as? NSIndexPath where indexPath.row > 0,
                let gid = groupArray[indexPath.row - 1].gid,
                let gname = groupArray[indexPath.row - 1].gname
            else{
                return
            }
            if type==1{
                let indexPath = sender as! NSIndexPath
                let group = self.groupArray[indexPath.row-1]
                vc.group = group
            }
            
            vc.senderId = sendId
            vc.senderDisplayName = nickname
            vc.currentAvatar = UIImage(named: "联系人-蓝.png")
            // TODO: pass the friend or group to me
            vc.receiverId = String(gid)
            vc.receiverName = gname
        }
    }

}
