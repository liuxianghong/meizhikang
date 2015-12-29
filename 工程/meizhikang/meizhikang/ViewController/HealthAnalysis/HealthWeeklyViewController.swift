//
//  HealthWeeklyViewController.swift
//  meizhikang
//
//  Created by shadowPriest on 15/12/4.
//  Copyright © 2015年 刘向宏. All rights reserved.
//

import UIKit
enum HealthWeeklyType{
    case Week
    case Month
}
struct WeeklyViewLineData{
    var date: NSDate
    var value: CGFloat
}
class HealthWeeklyViewController: UIViewController {

    @IBOutlet weak var typeTitle: UIButton!
    @IBOutlet weak var avgLabel: UILabel!
    @IBOutlet weak var chartView: HealthWeeklyChartView!
    @IBOutlet weak var lastPercent: HealthPercentView!
    var type: HealthWeeklyType?
    var currentDay: NSDate?
    var chartData: [WeeklyViewLineData] = [WeeklyViewLineData]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        if self.type! == .Week{
            for i in 0..<7{
                let minDate = NSCalendar.currentCalendar().dateByAddingUnit(.Day, value: -i, toDate: currentDay!, options: NSCalendarOptions(rawValue: 0))
                let maxDate = NSCalendar.currentCalendar().dateByAddingUnit(.Day, value: -i + 1, toDate: currentDay!, options: NSCalendarOptions(rawValue: 0))
                let datas = UserInfo.CurrentUser()?.healthDatas(minDate!, maxTime: maxDate!)
                if datas?.count > 0 {
                    let value = (datas?.reduce(0, combine: { (item, data) -> CGFloat in
                        return item + CGFloat(data.healthValue!)
                    }))! / CGFloat((datas?.count)!)
                    let data = WeeklyViewLineData(date: minDate!, value: value)
                    chartData.append(data)
                }else{
                    chartData.append(WeeklyViewLineData(date: minDate!, value: 0))
                }
            }
            chartData = chartData.reverse()
            chartView.chartData = chartData
            chartView.setNeedsDisplay()
            guard let minDate = NSCalendar.currentCalendar().dateByAddingUnit(.Day, value: -7, toDate: currentDay!, options: NSCalendarOptions(rawValue: 0)),
                let maxDate = NSCalendar.currentCalendar().dateByAddingUnit(.Day, value: 1, toDate: currentDay!, options: NSCalendarOptions(rawValue: 0))else{
                    return
            }
            if let data = UserInfo.CurrentUser()?.healthDatas(minDate, maxTime: maxDate) where data.count > 0{
            (self.lastPercent.healthPercent.text,self.lastPercent.semiHealthPercent.text,self.lastPercent.weakPercent.text,self.lastPercent.unHealthPercent.text,self.avgLabel.text) = dayStrings(data, fromDayOffset: -7, toDayOffset: 0)
            }
            self.typeTitle.setTitle("前七天", forState: .Normal)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    func dayStrings(data: [HealthData],fromDayOffset: Int,toDayOffset: Int) -> (String?,String?,String?,String?,String?){
        let filterData = data.filter { (item) -> Bool in
            return dateIn(fromDayOffset, offset2: toDayOffset, date: item.time!)
        }
        guard filterData.count>0 else{
            return ("N/A","N/A","N/A","N/A","00")
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
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
