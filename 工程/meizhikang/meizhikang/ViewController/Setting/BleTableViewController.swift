//
//  BleTableViewController.swift
//  meizhikang
//
//  Created by 刘向宏 on 15/11/29.
//  Copyright © 2015年 刘向宏. All rights reserved.
//

import UIKit

class BleTableViewController: UIViewController ,BLEConnectDelegate {

    @IBOutlet weak var tableView : UITableView!
    @IBOutlet weak var bleSwitch : UISwitch!
    @IBOutlet weak var rightBar : UIBarButtonItem!
    @IBOutlet var rightDisconnectBar : UIBarButtonItem!
    var tableViewArray = []
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        BLEConnect.Instance().connectDelegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        BLEConnect.Instance().connectDelegate = self
        if BLEConnect.Instance().connectedPeripheral() != nil{
            self.navigationItem.setRightBarButtonItems([rightBar,rightDisconnectBar], animated: false)
        }
        else
        {
            self.navigationItem.setRightBarButtonItems([rightBar], animated: false)
        }
        tableViewArray = BLEConnect.Instance().peripherals()
        self.tableView.reloadData()
    }
    
    override func viewWillDisappear(animated: Bool) {
        rightBar.title = "扫描"
        //BLEConnect.Instance().stopScan()
        tableViewArray = []
        self.tableView.reloadData()
    }

    @IBAction func scanClick(sender : AnyObject) {
        rightBar.title = "扫描"
        tableViewArray = []
        BLEConnect.Instance().startScan()
        self.tableView.reloadData()
        
    }
    
    @IBAction func disConnectClick(sender : AnyObject) {
        BLEConnect.Instance().disconnect(BLEConnect.Instance().connectedPeripheral())
    }
    
    // MARK: - BLEConnectDelegate
    
    func peripheralFound(){
        tableViewArray = BLEConnect.Instance().peripherals()
        self.tableView.reloadData()
    }
    
    func setConnect() {
        self.navigationItem.setRightBarButtonItems([rightBar,rightDisconnectBar], animated: false)
        self.tableView.reloadData()
    }
    
    func setDisconnect() {
        self.navigationItem.setRightBarButtonItems([rightBar], animated: false)
        self.tableView.reloadData()
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
        let peripheral = tableViewArray[indexPath.row] as! CBPeripheral
        if BLEConnect.Instance().connectedPeripheral() != nil{
            if BLEConnect.Instance().connectedPeripheral().isEqual(peripheral){
               return
            }
        }
         BLEConnect.Instance().connect(peripheral)
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 20;
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "设备列表"
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell:SettingTableViewCell = tableView.dequeueReusableCellWithIdentifier("settingIndentifer", forIndexPath: indexPath) as! SettingTableViewCell
        
        // Configure the cell...
        let peripheral = tableViewArray[indexPath.row] as! CBPeripheral
        cell.titleLabel.text = peripheral.name
        cell.stateImageView.hidden = true
        if BLEConnect.Instance().connectedPeripheral() != nil{
            if BLEConnect.Instance().connectedPeripheral().isEqual(peripheral){
                cell.stateImageView.hidden = false
            }
        }
        
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
