//
//  HealthDailyViewController.swift
//  meizhikang
//
//  Created by shadowPriest on 15/12/4.
//  Copyright © 2015年 刘向宏. All rights reserved.
//

import UIKit

class HealthDailyViewController: UIViewController {

    @IBOutlet weak var todayPercent: HealthPercentView!
    @IBOutlet weak var yesterdayPercent: HealthPercentView!
    @IBOutlet weak var lastweekPercent: HealthPercentView!
    @IBOutlet weak var lastmonthPercent: HealthPercentView!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.todayPercent.healthPercent.text = "a"
        self.yesterdayPercent.healthPercent.text = "a"
        self.lastweekPercent.healthPercent.text = "a"
        self.lastmonthPercent.healthPercent.text = "a"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func weeklyReportClicked(sender: UIButton) {
    }

    @IBAction func monthlyReportClicked(sender: UIButton) {
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
