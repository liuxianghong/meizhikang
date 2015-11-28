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
    @IBOutlet  weak var tableView:UITableView!
    let tableViewArray = ["BLUEDIAODIAO","健康图","健康分析","蓝牙连接","我的好友","设置"]
    let viewArray = ["sw_BLUEDIAODIAO","sw_front","sw_analysis","sw_ble","sw_friend","sw_setting"]
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.revealViewController().frontIdentfierArray = viewArray
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
        cell.titleLabel.text = title
    
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if self.revealViewController() != nil{
            let dic = self.revealViewController().frontViewControllersDic;
            let vc:UIViewController = dic.objectForKey(viewArray[indexPath.row]) as! UIViewController;
            if !vc.isEqual(self.revealViewController().frontViewController){
                self.revealViewController().setFrontViewController(vc, animated: true)
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
