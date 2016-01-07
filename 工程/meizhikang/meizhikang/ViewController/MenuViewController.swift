//
//  MenuViewController.swift
//  meizhikang
//
//  Created by 刘向宏 on 15/11/28.
//  Copyright © 2015年 刘向宏. All rights reserved.
//

import UIKit

class MenuViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {
    
    @IBOutlet  weak var imageView:UIImageView!
    @IBOutlet  weak var imageView2:UIImageView!
    @IBOutlet  weak var tableView:UITableView!
    let imageViewArray = ["轮换图1","轮换图2","轮换图3"]
    var imageViewTag = 1
    let tableViewArray = ["BLUEDIAODIAO","健康图","健康分析","蓝牙连接","我的好友","设置"]
    let viewArray = ["sw_BLUEDIAODIAO","sw_front","sw_analysis","sw_ble","sw_friend","sw_setting"]
    var stopAnimation = false
    
    var userName = "未登录"
    var nameLabel : UILabel!
    var currentIndex = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.revealViewController().frontIdentfierArray = viewArray
        
        NSNotificationCenter.defaultCenter().addObserverForName("didLogoutNotification", object: nil, queue: NSOperationQueue.mainQueue()) { (notif : NSNotification) -> Void in
            
            if self.revealViewController() != nil{
                self.revealViewController().setFrontViewPosition(.Left, animated: true)
                let dic = self.revealViewController().frontViewControllersDic;
                for obj in dic.allValues{
                    if let vc = obj as? UINavigationController{
                        vc.popToRootViewControllerAnimated(false)
                    }
                }
                let vc:UIViewController = dic.objectForKey("sw_front") as! UIViewController;
                if !vc.isEqual(self.revealViewController().frontViewController){
                    self.revealViewController().pushFrontViewController(vc, animated: false)
                }
                self.currentIndex = 1
            }
        }
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.stopAnimation = false
        self.doHideImage()
        let nickname = UserInfo.nickname()
        if nickname != nil{
            userName = nickname!
        }
        else{
            userName = "未登录"
        }
        tableView.reloadData()
        tableView.selectRowAtIndexPath(NSIndexPath(forRow: currentIndex, inSection: 0), animated: false, scrollPosition: .None)
        
    }
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        self.stopAnimation = true
    }
    
    func doHideImage(){
        if !self.stopAnimation{
            UIView.animateWithDuration(4.0, animations: { () -> Void in
                self.imageView.alpha = 0.0
                self.imageView2.alpha = 1.0
                }) { (Bool) -> Void in
                    self.imageViewTag++
                    self.imageViewTag = self.imageViewTag % 3
                    self.imageView.image = UIImage(named: self.imageViewArray[self.imageViewTag])
                    self.doShowImage()
            }
        }
    }
    
    func doShowImage(){
        if !self.stopAnimation{
            UIView.animateWithDuration(4.0, animations: { () -> Void in
                self.imageView2.alpha = 0.0
                self.imageView.alpha = 1.0
                }) { (Bool) -> Void in
                    self.imageViewTag++
                    self.imageViewTag = self.imageViewTag % 3
                    self.imageView2.image = UIImage(named: self.imageViewArray[self.imageViewTag])
                    self.doHideImage()
            }
        }
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
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell:MenuTableViewCell = tableView.dequeueReusableCellWithIdentifier("menuCellIdentifier", forIndexPath: indexPath) as! MenuTableViewCell
    
    // Configure the cell...
        let title = tableViewArray[indexPath.row] 
        cell.iconImage.image = UIImage(named: "\(title)-绿")
        cell.iconImage.highlightedImage = UIImage(named: "\(title)")
        if indexPath.row == 0{
            cell.titleLabel.text = userName
            //cell.selectionStyle = .None
        }
        else{
            cell.titleLabel.text = title
            //cell.selectionStyle = .Default
        }
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if self.revealViewController() != nil{
            
//            if indexPath.row != 1 && indexPath.row != 3{
//                if UserInfo.CurrentUser() == nil{
//                    self.revealViewController().navigationController?.performSegueWithIdentifier("loginIdentifier", sender: nil)
//                    self.tableView.reloadData()
//                    tableView.selectRowAtIndexPath(indexPath, animated: false, scrollPosition: .None)
//                    //self.revealViewController().revealToggleAnimated(true)
//                    return;
//                }
//            }
//            if indexPath.row == 0{
//                self.tableView.reloadData()
//                tableView.selectRowAtIndexPath(NSIndexPath(forRow: currentIndex, inSection: 0), animated: false, scrollPosition: .None)
//                //self.revealViewController().revealToggleAnimated(true)
//                return;
//            }
            currentIndex = indexPath.row
            let dic = self.revealViewController().frontViewControllersDic;
            let vc:UIViewController = dic.objectForKey(viewArray[indexPath.row]) as! UIViewController;
            if !vc.isEqual(self.revealViewController().frontViewController){
                self.revealViewController().pushFrontViewController(vc, animated: false)
            }
            self.revealViewController().revealToggleAnimated(true)
        }
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
