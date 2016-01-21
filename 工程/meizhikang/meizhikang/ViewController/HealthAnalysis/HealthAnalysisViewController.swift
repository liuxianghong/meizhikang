
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
    var cache: NSCache!
    var loadingData = false
    let todayDate = NSCalendar.currentCalendar().dateByAddingUnit(.Hour, value: 20, toDate: NSCalendar.currentCalendar().startOfDayForDate(NSDate()), options: NSCalendarOptions(rawValue: 0))
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.automaticallyAdjustsScrollViewInsets = false
        self.cache = NSCache()
        self.cache.evictsObjectsWithDiscardedContent = false
        self.loadingData = true
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)){
            for i in -120...0{
                let currentDate = self.calendarView!.currentPage
                guard
                    let user = UserInfo.CurrentUser(),
                    let date = NSCalendar.currentCalendar().dateByAddingUnit(.Hour, value: -4, toDate: currentDate, options: NSCalendarOptions(rawValue: 0)),
                    let cDate = NSCalendar.currentCalendar().dateByAddingUnit(.Day, value: i, toDate: date, options: NSCalendarOptions(rawValue: 0)) else{
                    continue
                }
                self.cache.setObject("\(user.healthDataHaveDataOn(cDate))", forKey: cDate)
            }
            dispatch_async(dispatch_get_main_queue()){
                self.loadingData = false
                self.calendarView.reloadData()
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func toSystemDate(date: NSDate!) -> NSDate{
        let currentGMT = NSTimeZone(abbreviation: "GMT")
        let currentZone = NSTimeZone.systemTimeZone()
        let interval = (currentGMT?.secondsFromGMTForDate(date))! - currentZone.secondsFromGMTForDate(date)
        return NSDate(timeInterval: NSTimeInterval(interval), sinceDate: date)
    }
    
    func cacheDay(date: NSDate) -> Bool{
        if let str = self.cache.objectForKey(date) as? String{
           return str == "true"
        }else{
            guard let user = UserInfo.CurrentUser() else{
                return false
            }
            let storeBool = user.healthDataHaveDataOn(date)
            self.cache.setObject("\(storeBool)", forKey: date)
            return storeBool
        }
    }
    
    func calendar(calendar: FSCalendar!, didSelectDate date: NSDate!) {
        calendar.deselectDate(date)
        guard let dataDate = NSCalendar.currentCalendar().dateByAddingUnit(.Hour, value: -4, toDate: date, options: NSCalendarOptions(rawValue: 0)),
            let user = UserInfo.CurrentUser() else{
            return
        }
        if dataDate.compare(self.todayDate!) != .OrderedAscending{
            return
        }
        if user.healthDataHaveDataOn(dataDate) {
            self.performSegueWithIdentifier(HealthAnalysisConstant.HealthAnalysisSegueIdentifier, sender: date)
        }
    }
    
    func calendar(calendar: FSCalendar!, hasEventForDate date: NSDate!) -> Bool{
        if self.loadingData {
            return false
        }
        let systemDate = date
        guard let cDate = NSCalendar.currentCalendar().dateByAddingUnit(.Hour, value: -4, toDate: systemDate, options: NSCalendarOptions(rawValue: 0)) else{
            return false
        }
        if cDate.compare(self.todayDate!) != .OrderedAscending{
           return false
        }
        let todayComponents = NSCalendar.currentCalendar().componentsInTimeZone(NSTimeZone.systemTimeZone(), fromDate: NSDate())
        let dateComponents = NSCalendar.currentCalendar().components(NSCalendarUnit(rawValue: UInt.max), fromDate: date)
        if todayComponents.year == dateComponents.year && todayComponents.month == dateComponents.month && todayComponents.day == dateComponents.day{
            return NSDate().compare(self.todayDate!) == .OrderedDescending
        }
        return self.cacheDay(cDate)
    }
    
    func calendarCurrentPageDidChange(calendar: FSCalendar!) {
        let currentDate = self.calendarView!.currentPage
        guard let date = NSCalendar.currentCalendar().dateByAddingUnit(.Hour, value: -4, toDate: currentDate, options: NSCalendarOptions(rawValue: 0)) else{
            return
        }
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)){
            for i in -120...0{
                guard
                    let pDate = NSCalendar.currentCalendar().dateByAddingUnit(.Day, value: i, toDate: date, options: NSCalendarOptions(rawValue: 0)) else{
                    continue
                }
                if self.cache.objectForKey(pDate) != nil{
                    break
                }
                self.cacheDay(pDate)
            }
        }
        
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
