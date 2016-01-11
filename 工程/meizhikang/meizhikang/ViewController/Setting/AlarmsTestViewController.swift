//
//  AlarmsTestViewController.swift
//  meizhikang
//
//  Created by 刘向宏 on 16/1/11.
//  Copyright © 2016年 刘向宏. All rights reserved.
//

import UIKit

class AlarmsTestViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func testClick(){
        NSNotificationCenter.defaultCenter().postNotificationName("RingSwichOnNotification", object: nil)
        BLEConnect.Instance().ternOnRing(60)
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
