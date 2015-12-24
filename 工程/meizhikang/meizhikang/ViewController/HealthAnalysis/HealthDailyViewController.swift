//
//  HealthDailyViewController.swift
//  meizhikang
//
//  Created by shadowPriest on 15/12/4.
//  Copyright © 2015年 刘向宏. All rights reserved.
//

import UIKit
struct DailyViewLineData{
    var position: CGFloat
    var value: NSInteger
}
class HealthDailyViewController: UIViewController {

    @IBOutlet weak var chartView: HealthDailyChartView!
    @IBOutlet weak var todayPercent: HealthPercentView!
    @IBOutlet weak var yesterdayPercent: HealthPercentView!
    @IBOutlet weak var lastweekPercent: HealthPercentView!
    @IBOutlet weak var lastmonthPercent: HealthPercentView!
    var currentDayData: [HealthData]?
    var currentDay: NSDate?
    var viewsData: [DailyViewLineData]?
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.todayPercent.healthPercent.text = "a"
        self.yesterdayPercent.healthPercent.text = "a"
        self.lastweekPercent.healthPercent.text = "a"
        self.lastmonthPercent.healthPercent.text = "a"
        if let data = UserInfo.CurrentUser()?.healthDatas?.allObjects as? [HealthData]{
            self.currentDayData = data.filter({ (data) -> Bool in
                return NSCalendar.currentCalendar().isDate(self.currentDay!, inSameDayAsDate: data.time!)
            })
            self.viewsData = self.currentDayData?.map({ (data) -> DailyViewLineData in
                let pos = CGFloat((data.time?.timeIntervalSinceDate(self.currentDay!))!)
                let v = Int(data.healthValue!)
                return DailyViewLineData(position: pos / CGFloat(24*60*60), value: v)
            })
            self.chartView.data = self.viewsData
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.chartView.setNeedsDisplay()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func weeklyReportClicked(sender: UIButton) {
        self.chartView.backgroundColor = UIColor.whiteColor()
        self.chartView.setNeedsDisplay()
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
