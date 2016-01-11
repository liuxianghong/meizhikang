//
//  HealthAnalysisViewController.swift
//  meizhikang
//
//  Created by shadowPriest on 15/11/29.
//  Copyright © 2015年 刘向宏. All rights reserved.
//

import UIKit
import FSCalendar

struct HealthAnalysisConstant{
    static let HealthAnalysisSegueIdentifier = "HealthReportSegueIdentifier"
}

@IBDesignable
class HealthAnalysisViewController: UIViewController,FSCalendarDelegate,FSCalendarDataSource{

    @IBOutlet weak var topConstraint: NSLayoutConstraint!
    @IBOutlet weak var calendarView: FSCalendar!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.automaticallyAdjustsScrollViewInsets = false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func calendar(calendar: FSCalendar!, didSelectDate date: NSDate!) {
        let currentGMT = NSTimeZone(abbreviation: "GMT")
        let currentZone = NSTimeZone.systemTimeZone()
        let interval = (currentGMT?.secondsFromGMTForDate(date))! - currentZone.secondsFromGMTForDate(date)
        let currentTimeZoneDate = NSDate(timeInterval: NSTimeInterval(interval), sinceDate: date)
        self.performSegueWithIdentifier(HealthAnalysisConstant.HealthAnalysisSegueIdentifier, sender: currentTimeZoneDate)
        calendar.deselectDate(date)
        print(NSTimeZone.systemTimeZone().secondsFromGMT)
    }
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if self.revealViewController() != nil{
            self.revealViewController().setFrontViewPosition(.Left, animated: true)
        }
        
        guard let identifier = segue.identifier else{
            return
        }
        if identifier == HealthAnalysisConstant.HealthAnalysisSegueIdentifier{
            let vc = segue.destinationViewController as! HealthReportViewController
            let date = sender as! NSDate
            vc.date = date
        }
    }

}
