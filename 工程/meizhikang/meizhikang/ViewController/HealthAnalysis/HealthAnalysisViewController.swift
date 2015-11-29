//
//  HealthAnalysisViewController.swift
//  meizhikang
//
//  Created by shadowPriest on 15/11/29.
//  Copyright © 2015年 刘向宏. All rights reserved.
//

import UIKit

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
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        calendarView.frame = CGRectMake(0, 64, CGRectGetWidth(self.view.bounds), 300)
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
