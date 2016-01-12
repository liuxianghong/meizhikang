//
//  FriendListTableViewController.swift
//  meizhikang
//
//  Created by 刘向宏 on 15/11/28.
//  Copyright © 2015年 刘向宏. All rights reserved.
//

import UIKit
import MagicalRecord
import MBProgressHUD

struct FriendListTableViewControllerConstant{
    static let chatSegueIdentifier = "ChatSegueIdentifier"
}

class FriendListTableViewController: UITableViewController {

    @IBOutlet weak var typeImageView1 : UIImageView!
    @IBOutlet weak var typeImageView2 : UIImageView!
    @IBOutlet weak var typeImageView3 : UIImageView!
    var emptyLabel = UILabel()
    var groupArray :Array<Group> = []
    var emailArray = [Email]()
    var chatArray = [Chat]()
    var type = 1
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        typeImageView2.hidden = true;
        typeImageView3.hidden = true;
        
        self.tableView.addSubview(emptyLabel)
        emptyLabel.text = "无群组会话"
        emptyLabel.frame = CGRectMake(0, tableView.frame.size.height/2, tableView.frame.size.width, 30)
        emptyLabel.textAlignment = .Center
        
        var frame = self.tableView.tableHeaderView?.frame
        frame?.size.height = 50.0
        self.tableView.tableHeaderView?.frame = frame!
        
        NSNotificationCenter.defaultCenter().addObserverForName("groupChangeNotification", object: nil, queue: NSOperationQueue.mainQueue()) { (notification : NSNotification) -> Void in
            self.loadGrous()
            self.tableView.reloadData()
        }
        
        NSNotificationCenter.defaultCenter().addObserverForName("reciveEmailNotification", object: nil, queue: NSOperationQueue.mainQueue()) { (notification : NSNotification) -> Void in
            self.loadEmail()
            self.tableView.reloadData()
        }
        
        NSNotificationCenter.defaultCenter().addObserverForName("reciveMessageNotification", object: nil, queue: NSOperationQueue.mainQueue()) { (notification : NSNotification) -> Void in
            if let mesage = notification.object as? Message{
                if mesage.chat != nil{
                    self.loadChat()
                    self.tableView.reloadData()
                }
                else
                {
                    self.loadGrous()
                    self.tableView.reloadData()
                }
            }
        }
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        loadEmail()
        loadGrous()
        loadChat()
        self.tableView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loadEmail(){
        if let user = UserInfo.CurrentUser(){
            emailArray.removeAll()
            for e in user.emails!{
                emailArray.append(e as! Email)
            }
        }
    }
    
    func loadChat(){
        if let user = UserInfo.CurrentUser(){
            chatArray.removeAll()
            for e in user.chats!{
                chatArray.append(e as! Chat)
            }
        }
    }
    
    func loadGrous(){
        if let user = UserInfo.CurrentUser(){
            groupArray.removeAll()
            for g in user.groups!{
                groupArray.append(g as! Group)
            }
            groupArray = groupArray.sort({ (g1 : Group, g2 : Group) -> Bool in
                return g1.createtime?.compare(g2.createtime!) == .OrderedAscending
            })
        }
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
            emptyLabel.hidden = !groupArray.isEmpty
            emptyLabel.text = "无群组会话"
            return self.groupArray.count + 1
        }
        else if type == 3{
            emptyLabel.hidden = !emailArray.isEmpty
            emptyLabel.text = "无系统消息"
            return emailArray.count
        }
        emptyLabel.hidden = !chatArray.isEmpty
        emptyLabel.text = "无会话"
        return chatArray.count
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
            cell.numberLabel.text = "\((group.members?.count)! as Int)"
        }
        else if type == 2{
            cell.typeImageView.image = UIImage(named: "联系人-蓝")
            let chat = chatArray[indexPath.row]
            cell.nameLabel.text = chat.member?.nickname
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
            let actionNew = UIAlertAction(title: "创建群", style: .Default, handler: { (ac :UIAlertAction) -> Void in
                let actionGroup = UIAlertController(title: "", message: "组名称", preferredStyle: .Alert)
                let actionA = UIAlertAction(title: "创建", style: .Default, handler: { (UIAlertAction) -> Void in
                    let tf = actionGroup.textFields![0]
                    let hud = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
                    IMRequst.CreateGroupByGid(tf.text, completion: { (object) -> Void in
                        print(object)
                        let joson = JSON(object)
                        let flag = joson["flag"].intValue
                        if flag == 1{
                            hud.detailsLabelText = "创建组成功";
                            UserInfo.CurrentUser()?.loadGrous()
                        }
                        else if flag == -1{
                            hud.detailsLabelText = "已经创建1个组";
                        }
                        else
                        {
                            hud.detailsLabelText = "创建组失败";
                        }
                        hud.mode = .Text
                        
                        hud.hide(true, afterDelay: 1.5)
                        
                        }, failure: { (error : NSError!) -> Void in
                            hud.mode = .Text
                            hud.detailsLabelText = error.domain;
                            hud.hide(true, afterDelay: 1.5)
                            print(error)
                    })
                })
                
                let actionC = UIAlertAction(title: "取消", style: .Cancel, handler: { (UIAlertAction) -> Void in
                    
                })
                actionGroup.addTextFieldWithConfigurationHandler({ (UITextField) -> Void in
                    
                })
                actionGroup.addAction(actionA)
                actionGroup.addAction(actionC)
                self.presentViewController(actionGroup, animated: true, completion: { () -> Void in
                    
                })
                
            })
            
            let actionAdd = UIAlertAction(title: "加入群", style: .Default, handler: { (UIAlertAction) -> Void in
                self.performSegueWithIdentifier("addMenberIdentifier", sender: nil)
            })
            
            let actionCancel = UIAlertAction(title: "取消", style: .Cancel, handler: { (UIAlertAction) -> Void in
                
            })
            
            actionVC.addAction(actionNew)
            actionVC.addAction(actionAdd)
            actionVC.addAction(actionCancel)
            
            self.presentViewController(actionVC, animated: true, completion: { () -> Void in
                
            })
        }else if type == 3{
            
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
        
        if self.revealViewController() != nil{
            self.revealViewController().setFrontViewPosition(.Left, animated: true)
        }
        
        if segue.identifier == FriendListTableViewControllerConstant.chatSegueIdentifier{
            
            if type==1{
                guard let vc = segue.destinationViewController as? ChatViewController,
                    let sendId = UserInfo.CurrentUser()?.uid,
                    let nickname = UserInfo.CurrentUser()?.nickname,
                    let indexPath = sender as? NSIndexPath where indexPath.row > 0,
                    let gid = groupArray[indexPath.row - 1].gid,
                    let gname = groupArray[indexPath.row - 1].gname
                    else{
                        return
                }
                let group = self.groupArray[indexPath.row-1]
                vc.group = group
                vc.senderId = sendId.stringValue
                vc.senderDisplayName = nickname
                vc.currentAvatar = UIImage(named: "联系人-蓝.png")
                // TODO: pass the friend or group to me
                vc.receiverId = String(gid)
                vc.receiverName = gname
            }
            else if type == 2{
                guard let vc = segue.destinationViewController as? ChatViewController,
                    let sendId = UserInfo.CurrentUser()?.uid,
                    let nickname = UserInfo.CurrentUser()?.nickname,
                    let indexPath = sender as? NSIndexPath,
                    let gid = chatArray[indexPath.row].member!.uid,
                    let gname = chatArray[indexPath.row].member!.nickname
                    else{
                        return
                }
                let chat = self.chatArray[indexPath.row]
                vc.chat = chat
                vc.senderId = sendId.stringValue
                vc.senderDisplayName = nickname
                vc.currentAvatar = UIImage(named: "联系人-蓝.png")
                // TODO: pass the friend or group to me
                vc.receiverId = String(gid)
                vc.receiverName = gname
            }
            
        }
        else if segue.identifier == "addMenberIdentifier"{
            let vc = segue.destinationViewController as! GroupAddMenbersViewController
            vc.type = 2
        }
    }

}
