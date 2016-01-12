//
//  GroupInformationTableViewController.swift
//  meizhikang
//
//  Created by 刘向宏 on 16/1/12.
//  Copyright © 2016年 刘向宏. All rights reserved.
//

import UIKit

class GroupInformationTableViewController: UITableViewController {

    var tableViewDic = [[String]]()
    var group : Group?
    var menber : GroupMember?
    @IBOutlet weak var imageView : UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        if let gname = group?.gname , let gcount = group?.members?.count , let time = group?.createtime{
            tableViewDic.append(["群组名称：",gname])
            tableViewDic.append(["成员人数：",String(gcount)])
            let cdate = NSDate(timeIntervalSince1970: NSTimeInterval(time))
            let formatter = NSDateFormatter()
            formatter.dateFormat = "yyyy年MM月dd日 hh时mm分"
            tableViewDic.append(["创建时间：",formatter.stringFromDate(cdate)])
            self.navigationItem.rightBarButtonItem = nil
        }
        else if let nickName = menber?.nickname , let time = menber?.createtime{
            self.title = "个人资料"
            tableViewDic.append(["昵称：",nickName])
            let cdate = NSDate(timeIntervalSince1970: NSTimeInterval(time))
            let formatter = NSDateFormatter()
            formatter.dateFormat = "yyyy年MM月dd日 hh时mm分"
            tableViewDic.append(["创建时间：",formatter.stringFromDate(cdate)])
            self.imageView.image = UIImage(named: "联系人-蓝.png")
        }
       
    }

    @IBAction func sendClick(sender : AnyObject?){
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return tableViewDic.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cellIndentifier", forIndexPath: indexPath)

        // Configure the cell...
        cell.textLabel?.text = tableViewDic[indexPath.row][0]
        cell.detailTextLabel?.text = tableViewDic[indexPath.row][1]

        return cell
    }
    
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        if cell.respondsToSelector("tintColor"){
            if tableView == self.tableView{
                let cornerRadius:CGFloat = 7
                cell.backgroundColor = UIColor.clearColor()
                let layer = CAShapeLayer()
                let pathRef = CGPathCreateMutable()
                let bounds = CGRectInset(cell.bounds, 10, 0)
                var addLine = false
                if indexPath.row == 0 {
                    CGPathMoveToPoint(pathRef, nil, CGRectGetMinX(bounds), CGRectGetMaxY(bounds))
                    CGPathAddArcToPoint(pathRef, nil, CGRectGetMinX(bounds), CGRectGetMinY(bounds), CGRectGetMidX(bounds), CGRectGetMinY(bounds), cornerRadius)
                    CGPathAddArcToPoint(pathRef, nil, CGRectGetMaxX(bounds), CGRectGetMinY(bounds), CGRectGetMaxX(bounds), CGRectGetMidY(bounds), cornerRadius)
                    CGPathAddLineToPoint(pathRef, nil, CGRectGetMaxX(bounds), CGRectGetMaxY(bounds))
                    addLine = true
                }else if indexPath.row == tableView.numberOfRowsInSection(indexPath.section) - 1{
                    CGPathMoveToPoint(pathRef, nil, CGRectGetMinX(bounds), CGRectGetMinY(bounds))
                    CGPathAddArcToPoint(pathRef, nil, CGRectGetMinX(bounds), CGRectGetMaxY(bounds), CGRectGetMidX(bounds), CGRectGetMaxY(bounds), cornerRadius)
                    CGPathAddArcToPoint(pathRef, nil, CGRectGetMaxX(bounds), CGRectGetMaxY(bounds), CGRectGetMaxX(bounds), CGRectGetMidY(bounds), cornerRadius)
                    CGPathAddLineToPoint(pathRef, nil, CGRectGetMaxX(bounds), CGRectGetMinY(bounds))
                }else {
                    CGPathAddRect(pathRef, nil, bounds);
                    addLine = true
                }
                layer.path = pathRef
                layer.fillColor = UIColor.whiteColor().CGColor
                layer.strokeColor = UIColor.darkGrayColor().CGColor
                if addLine {
                    let lineLayer = CALayer()
                    let lineHeight:CGFloat = (1.0 / UIScreen.mainScreen().scale);
                    lineLayer.frame = CGRectMake(CGRectGetMinX(bounds), bounds.size.height-lineHeight, bounds.size.width, lineHeight);
                    lineLayer.backgroundColor = UIColor.blackColor().CGColor;
                    layer.addSublayer(lineLayer)
                }
                let testView = UIView(frame: bounds)
                testView.layer.insertSublayer(layer, atIndex: 0)
                testView.backgroundColor = UIColor.clearColor()
                cell.backgroundView = testView;
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
