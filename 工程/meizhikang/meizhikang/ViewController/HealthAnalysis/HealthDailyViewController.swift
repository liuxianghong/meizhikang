//
//  HealthDailyViewController.swift
//  meizhikang
//
//  Created by shadowPriest on 15/12/4.
//  Copyright © 2015年 刘向宏. All rights reserved.
//

import UIKit
import MBProgressHUD
struct DailyViewLineData{
    var position: CGFloat
    var value: NSInteger
}
class HealthDailyViewController: UIViewController,UIScrollViewDelegate {

    @IBOutlet weak var scrollViewContainer: UIScrollView!
    @IBOutlet weak var coordinateView: UIView!
    @IBOutlet weak var coodinateWidth: NSLayoutConstraint!
    @IBOutlet weak var todayAvgLabel: UILabel!
    @IBOutlet weak var yesterdayAvgLabel: UILabel!
    @IBOutlet weak var lastweekAvgLabel: UILabel!
    @IBOutlet weak var lastmonthAvgLabel: UILabel!
    @IBOutlet weak var chartView: HealthDailyChartView!
    @IBOutlet weak var todayPercent: HealthPercentView!
    @IBOutlet weak var yesterdayPercent: HealthPercentView!
    @IBOutlet weak var lastweekPercent: HealthPercentView!
    @IBOutlet weak var lastmonthPercent: HealthPercentView!
    @IBOutlet weak var imageView1 : UIImageView!
    @IBOutlet weak var imageView2 : UIImageView!
    @IBOutlet weak var imageView3 : UIImageView!
    @IBOutlet weak var imageView4 : UIImageView!
    var currentDayData: [HealthData]?
    var currentDay: NSDate?
    var viewsData: [DailyViewLineData]?
    
    var currentScale: CGFloat = 1.0
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.scrollViewContainer.delegate = self
        self.scrollViewContainer.maximumZoomScale = 4.0
        self.scrollViewContainer.minimumZoomScale = 0.5
        self.scrollViewContainer.showsHorizontalScrollIndicator = false
        self.imageView1.backgroundColor = UIColor.helathColor(.Health)
        self.imageView2.backgroundColor = UIColor.helathColor(.Subhealth)
        self.imageView3.backgroundColor = UIColor.helathColor(.Infirm)
        self.imageView4.backgroundColor = UIColor.helathColor(.Unhealthy)
        self.imageView1.layer.masksToBounds = true
        self.imageView1.layer.cornerRadius = 15/2.0
        self.imageView2.layer.masksToBounds = true
        self.imageView2.layer.cornerRadius = 15/2.0
        self.imageView3.layer.masksToBounds = true
        self.imageView3.layer.cornerRadius = 15/2.0
        self.imageView4.layer.masksToBounds = true
        self.imageView4.layer.cornerRadius = 15/2.0
        
        self.todayPercent.healthPercent.text = "a"
        self.yesterdayPercent.healthPercent.text = "b"
        self.lastweekPercent.healthPercent.text = "c"
        self.lastmonthPercent.healthPercent.text = "d"
        guard let minDate = NSCalendar.currentCalendar().dateByAddingUnit(.Hour, value: -30 * 24 - 4, toDate: currentDay!, options: NSCalendarOptions(rawValue: 0)),
            let maxDate = NSCalendar.currentCalendar().dateByAddingUnit(.Hour, value: 20, toDate: currentDay!, options: NSCalendarOptions(rawValue: 0))else{
                return
        }
        if let data = UserInfo.CurrentUser()?.healthDatas(minDate, maxTime: maxDate) where data.count > 0{
            self.chartView.data = data.filter({ (data) -> Bool in
                return dateIn(0, offset2: 1, date: currentDay!)
            }).map({ (data) -> DailyViewLineData in
                let offsetDate = NSCalendar.currentCalendar().dateByAddingUnit(.Hour, value: -4, toDate: self.currentDay!, options: NSCalendarOptions(rawValue: 0))
                let pos = CGFloat((data.time?.timeIntervalSinceDate(offsetDate!))!)
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
            self.coodinateWidth.constant = self.view.bounds.size.width - 30
        }
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
        let from = NSCalendar.currentCalendar().dateByAddingUnit(.Hour, value: offset1 * 24 - 4, toDate: self.currentDay!, options: NSCalendarOptions(rawValue: 0))
        let to = NSCalendar.currentCalendar().dateByAddingUnit(.Hour, value: offset2 * 24 - 4, toDate: self.currentDay!, options: NSCalendarOptions(rawValue: 0))
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
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func generateDailyImage() -> UIImage?{
        let trans = self.chartView.transform
        defer{
            self.chartView.transform = trans
        }
        self.chartView.transform = CGAffineTransformIdentity
        return UIImage.imageWith(self.chartView)
    }
    
    func showHUD(str: String){
        let hud = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        hud.mode = .Text
        hud.detailsLabelText = str//
        hud.hide(true, afterDelay: 3.0)
        
    }
    @IBAction func weeklyReportClicked(sender: UIButton) {
//        self.chartView.setNeedsDisplay()
        share()
    }
    func share(){
        guard let vc = self.parentViewController as? HealthReportContainerViewController,
            let _ = UserInfo.CurrentUser()?.shareGroup,
            let image = generateDailyImage()
        else{
            showHUD("未开启群组分享,请开启")
            return
        }
        vc.performSegueWithIdentifier(HealthReportContainerConstant.ShareImageSegueIdentifier, sender: image)
    }

    @IBAction func monthlyReportClicked(sender: UIButton) {
        askExpert()
    }
    func askExpert(){
        showHUD("此项属于收费服务,在后续版本中提供")
    }
    
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return self.chartView
    }
    
    func scrollViewDidEndZooming(scrollView: UIScrollView, withView view: UIView?, atScale scale: CGFloat) {
        if fabs(scale - self.currentScale) < 1e-6 {
            return
        }
        print(self.chartView)
        if scale > 1.0 {
            if self.chartView.scale < 3.9{
                self.chartView.scale *= 2
            }
        }else{
            if self.chartView.scale > 1.1{
                self.chartView.scale /= 2
            }
        }
        scrollView.zoomScale = self.chartView.scale
        self.chartView.transform = CGAffineTransformIdentity
        self.coodinateWidth.constant = (self.view.bounds.size.width - 30) * self.chartView.scale
        scrollView.contentSize = CGSize(width: self.coodinateWidth.constant, height: 72.0)
        self.chartView.setNeedsDisplay()
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
