//
//  HealthReportViewController.swift
//  meizhikang
//
//  Created by shadowPriest on 15/12/2.
//  Copyright © 2015年 刘向宏. All rights reserved.
//

import UIKit
class HealthReportViewModel: NSObject{
    var date : NSDate
    init(date: NSDate){
        self.date = date
    }
}

class HealthReportViewController: UIViewController {
    

    let viewModel = HealthReportViewModel(date: NSDate())
    var date : NSDate? {
        willSet{
            guard let value = newValue else{
                return
            }
            self.viewModel.date = value
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
