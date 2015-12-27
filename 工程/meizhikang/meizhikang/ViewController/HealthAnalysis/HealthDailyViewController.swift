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

    @IBOutlet weak var todayAvgLabel: UILabel!
    @IBOutlet weak var yesterdayAvgLabel: UILabel!
    @IBOutlet weak var lastweekAvgLabel: UILabel!
    @IBOutlet weak var lastmonthAvgLabel: UILabel!
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
        self.yesterdayPercent.healthPercent.text = "b"
        self.lastweekPercent.healthPercent.text = "c"
        self.lastmonthPercent.healthPercent.text = "d"
        if let data = UserInfo.CurrentUser()?.healthDatasOneDay(currentDay!){
            self.chartView.data = data.map({ (data) -> DailyViewLineData in
                let pos = CGFloat((data.time?.timeIntervalSinceDate(self.currentDay!))!)
                let v = Int(data.healthValue!)
                return DailyViewLineData(position: pos / CGFloat(24*60*60), value: v)
            })
            
//            self.todayPercent.healthPercent.text = percentOf(data.filter({ (item) -> Bool in
//                return dateIn(0, offset2: 1, date: item.time!)
//            }), lowValue: 79, hightValue: 1000)
            (self.todayPercent.healthPercent.text,self.todayPercent.semiHealthPercent.text,
                self.todayPercent.weakPercent.text,self.todayPercent.unHealthPercent.text,self.todayAvgLabel.text) = dayStrings(data, fromDayOffset: 0, toDayOffset: 1)
            (self.yesterdayPercent.healthPercent.text,self.yesterdayPercent.semiHealthPercent.text,
                self.yesterdayPercent.weakPercent.text,self.yesterdayPercent.unHealthPercent.text,self.yesterdayAvgLabel.text) = dayStrings(data, fromDayOffset: -1, toDayOffset: 0)
            (self.lastweekPercent.healthPercent.text,self.lastweekPercent.semiHealthPercent.text,
                self.lastweekPercent.weakPercent.text,self.lastweekPercent.unHealthPercent.text,self.lastweekAvgLabel.text) = dayStrings(data, fromDayOffset: -7, toDayOffset: 0)
            (self.lastmonthPercent.healthPercent.text,self.lastmonthPercent.semiHealthPercent.text,
                self.lastmonthPercent.weakPercent.text,self.lastmonthPercent.unHealthPercent.text,self.lastmonthAvgLabel.text) = dayStrings(data, fromDayOffset: -30, toDayOffset: 0)
        }
    }
    
    func dayStrings(data: [HealthData],fromDayOffset: Int,toDayOffset: Int) -> (String?,String?,String?,String?,String?){
        let filterData = data.filter { (item) -> Bool in
            return dateIn(fromDayOffset, offset2: toDayOffset, date: item.time!)
        }
        let s1 = percentOf(filterData, lowValue: 79, hightValue: 1000)
        let s2 = percentOf(filterData, lowValue: 69, hightValue: 79)
        let s3 = percentOf(filterData, lowValue: 59, hightValue: 69)
        let s4 = String(100 - Int(s1)! - Int(s2)! - Int(s3)!)
        let s5 = NSString(format: "%.f", filterData.reduce(0.0) { (added, item) -> Float in
            return added + Float(item.healthValue!)
        } / Float(filterData.count)) as String
        return (s1 + "%",s2 + "%",s3 + "%",s4 + "%",s5)
    }
    func percentOf(data: [HealthData],lowValue: Int,hightValue: Int) -> String{
        let filterDataCount = CGFloat(data.filter { (item) -> Bool in
            return ((lowValue < Int(item.healthValue!))&&(Int(item.healthValue!) <= hightValue))
        }.count)
        let count = CGFloat(data.count)
        return (NSString(format: "%.f", filterDataCount / count * 100) as String)
    }
    
    func dateIn(offset1: Int,offset2: Int,date: NSDate) -> Bool{
        let from = NSCalendar.currentCalendar().dateByAddingUnit(.Day, value: offset1, toDate: self.currentDay!, options: NSCalendarOptions(rawValue: 0))
        let to = NSCalendar.currentCalendar().dateByAddingUnit(.Day, value: offset2, toDate: self.currentDay!, options: NSCalendarOptions(rawValue: 0))
        if date.compare(from!) == .OrderedAscending{
            return false
        }
        if date.compare(to!) == .OrderedDescending{
            return false
        }
        return true
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
