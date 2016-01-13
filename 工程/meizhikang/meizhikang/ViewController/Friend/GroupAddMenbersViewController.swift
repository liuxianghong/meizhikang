//
//  GroupAddMenbersViewController.swift
//  meizhikang
//
//  Created by 刘向宏 on 16/1/13.
//  Copyright © 2016年 刘向宏. All rights reserved.
//

import UIKit
import MBProgressHUD

class GroupAddMenbersViewController: UIViewController , UITextFieldDelegate ,UITableViewDelegate,UITableViewDataSource{

    var group : Group?
    var type = 1
    @IBOutlet weak var field1 : UITextField!
    @IBOutlet weak var field2 : UITextField!
    @IBOutlet weak var view2 : UIView!
    @IBOutlet weak var tableView : UITableView!
    var tableViewArray = [AnyObject]()
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        if type != 1{
            self.title = "查找群组"
            view2.hidden = true
            field2.hidden = true
            field1.keyboardType = .Default
            field1.placeholder = "请输入待查找群组的名称"
        }
        self.tableView.tableFooterView = UIView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func okClick(sender : AnyObject?){
        field1.resignFirstResponder()
        field2.resignFirstResponder()
        let hud = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        if type != 1{
            if field1.text!.isEmpty{
                hud.mode = .Text
                hud.detailsLabelText = "请输入查询信息"
                hud.hide(true, afterDelay: 1)
                return
            }
            MZKSearchRequst.SearchGroupWithParameters(field1.text!, success: { (object : AnyObject!) -> Void in
                print(object)
                if let array = object as? Array<AnyObject>{
                    self.tableViewArray = array
                    self.tableView.reloadData()
                }
                hud.hide(true)
                
                }, failure: { (error : NSError!) -> Void in
                    hud.mode = .Text
                    hud.detailsLabelText = error.domain
                    hud.hide(true, afterDelay: 1)
            })
            
        }
        else{
            if field1.text!.isEmpty && field2.text!.isEmpty{
                hud.mode = .Text
                hud.detailsLabelText = "请输入查询信息"
                hud.hide(true, afterDelay: 1)
                return
            }
            var dic = ""
            if !field1.text!.isEmpty{
                dic = "accountName=\(field1.text!)"
            }
            if !field2.text!.isEmpty{
                let dic2 = "nickName=\(field2.text!)"
                if dic.isEmpty {
                    dic = dic2
                }
                else
                {
                    dic = "\(dic)&\(dic2)"
                }
            }
            
            MZKSearchRequst.SearchMemberWithParameters(dic, success: { (object : AnyObject!) -> Void in
                print(object)
                if let array = object as? Array<AnyObject>{
                    self.tableViewArray = array
                    self.tableView.reloadData()
                }
                hud.hide(true)
                
                }, failure: { (error : NSError!) -> Void in
                    hud.mode = .Text
                    hud.detailsLabelText = error.domain
                    hud.hide(true, afterDelay: 1)
            })
        }
    }
    //

    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    // MARK: - Table view data source
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return tableViewArray.count
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        let dic = tableViewArray[indexPath.row] as! Dictionary<String, AnyObject>
        var message = ""
        if type != 1{
            let name = dic["groupName"] as! String
            message = "是否要加入组\"\(name)\""
        }
        else{
            let name = dic["nickName"] as! String
            message = "是否要邀请\"\(name)\"加入群组\"\(group!.gname!)\""
        }
        
        let actionVC = UIAlertController(title: "", message: message, preferredStyle: .Alert)
        let actionlogin = UIAlertAction(title: "确定", style: .Default, handler: { (ac :UIAlertAction) -> Void in
            
            let hud = MBProgressHUD.showHUDAddedTo(self.view.window, animated: true)
            if self.type != 1{
                IMRequst.ApplyGroupByGid(dic["id"] as! Int, completion: { (object : AnyObject!) -> Void in
                    print(object)
                    let joson = JSON(object)
                    let flag = joson["flag"].intValue
                    if flag == 1{
                        hud.detailsLabelText = "申请成功，等待审核";
                    }
                    else if flag == -2{
                        hud.detailsLabelText = "重复申请，已经在组里"
                    }
                    else
                    {
                        hud.detailsLabelText = "申请失败";
                    }
                    hud.mode = .Text
                    
                    hud.hide(true, afterDelay: 1.5)
                    }, failure: { (error : NSError!) -> Void in
                        hud.mode = .Text
                        hud.detailsLabelText = error.domain
                        hud.hide(true, afterDelay: 1.5)
                })
            }
            else{
                IMRequst.AddMemberByGid(self.group?.gid, uid: dic["id"] as! Int, completion: { (object : AnyObject!) -> Void in
                    print(object)
                    let joson = JSON(object)
                    let flag = joson["flag"].intValue
                    if flag == 1{
                        hud.detailsLabelText = "添加邀请成功";
                    }
                    else if flag == -1{
                        hud.detailsLabelText = "添加失败，成员已经在组中"
                    }
                    else
                    {
                        hud.detailsLabelText = "申请失败";
                    }
                    hud.mode = .Text
                    
                    hud.hide(true, afterDelay: 1.5)
                    }, failure: { (error : NSError!) -> Void in
                        hud.mode = .Text
                        hud.detailsLabelText = error.domain
                        hud.hide(true, afterDelay: 1.5)
                })
            }
        })
        let actionCancel = UIAlertAction(title: "取消", style: .Cancel, handler: { (UIAlertAction) -> Void in
        })
        
        actionVC.addAction(actionlogin)
        actionVC.addAction(actionCancel)
        
        self.presentViewController(actionVC, animated: true, completion: { () -> Void in
            
        })
    }
    //[{"id":4145,"accountName":"12345671","nickName":"饼总"}]
    //[{"id":159,"etag":0,"groupName":"xiaomayi","ctime":"May 19, 2015 4:01:11 PM","memberSize":1,"adminNickName":"mayi","adminAccountName":"xingjindemayi"}]
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("indentifier", forIndexPath: indexPath)
        
        // Configure the cell...
        let dic = tableViewArray[indexPath.row] as! Dictionary<String, AnyObject>
        if self.type != 1{
            cell.imageView?.image = UIImage(named: "通讯2.png")
            cell.textLabel?.text = dic["groupName"] as? String
        }
        else{
            cell.imageView?.image = UIImage(named: "联系人-蓝.png")
            cell.textLabel?.text = dic["nickName"] as? String
        }
        
        return cell
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
