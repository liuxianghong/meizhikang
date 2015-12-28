//
//  HealthReportContainerViewController.swift
//  meizhikang
//
//  Created by shadowPriest on 15/12/4.
//  Copyright © 2015年 刘向宏. All rights reserved.
//

import UIKit
struct HealthReportContainerConstant{
    static let WeeklySegueIdentifier = "HealthWeeklySegueIdentifier"
    static let DailySegueIdentifier = "HealthDailySegueIdentifier"
}

class HealthReportContainerViewController: UIViewController {

    var currentSegueIdentifier = HealthReportContainerConstant.DailySegueIdentifier
    var date : NSDate?
    var weekType: HealthWeeklyType?
    var dailyViewController : HealthDailyViewController?
    var weeklyViewController : HealthWeeklyViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.performSegueWithIdentifier(self.currentSegueIdentifier, sender: self.date)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == HealthReportContainerConstant.DailySegueIdentifier{
            self.dailyViewController = segue.destinationViewController as? HealthDailyViewController
            self.dailyViewController?.currentDay = self.date
        }
        
        if segue.identifier == HealthReportContainerConstant.WeeklySegueIdentifier{
            self.weeklyViewController = segue.destinationViewController as? HealthWeeklyViewController
            self.weeklyViewController?.type = self.weekType
            self.weeklyViewController?.currentDay = self.date
        }
        
        if segue.identifier == HealthReportContainerConstant.DailySegueIdentifier{
            guard let dailyViewController = self.dailyViewController else{
                return
            }
            if self.childViewControllers.count > 0 {
                self.swapViewContoller(self.childViewControllers[0], toViewController: dailyViewController)
            }else{
                self.addChildViewController(dailyViewController)
                self.view.addSubview(dailyViewController.view)
                let v = dailyViewController.view
                v.translatesAutoresizingMaskIntoConstraints = false
                let constraint = NSLayoutConstraint.constraintsWithVisualFormat("|[v]|", options: .DirectionLeadingToTrailing, metrics: nil, views: ["v":v])
                let vConstraint = NSLayoutConstraint.constraintsWithVisualFormat("V:|[v]|", options: .DirectionLeadingToTrailing, metrics: nil, views: ["v":v])
                self.view.addConstraints(constraint)
                self.view.addConstraints(vConstraint)
            }
        }
        if segue.identifier == HealthReportContainerConstant.WeeklySegueIdentifier{
            guard let weeklyViewController = self.weeklyViewController else{
                return
            }
            swapViewContoller(self.childViewControllers[0], toViewController: weeklyViewController)
        }
    }
    
    func swapViewContoller(fromViewController: UIViewController,toViewController: UIViewController){
        fromViewController.willMoveToParentViewController(nil)
        self.addChildViewController(toViewController)
        self.transitionFromViewController(fromViewController, toViewController: toViewController, duration: 1.0, options: .TransitionCrossDissolve, animations: {
            let v = toViewController.view
            v.translatesAutoresizingMaskIntoConstraints = false
            let constraint = NSLayoutConstraint.constraintsWithVisualFormat("|[v]|", options: .DirectionLeadingToTrailing, metrics: nil, views: ["v":v])
            let vConstraint = NSLayoutConstraint.constraintsWithVisualFormat("V:|[v]|", options: .DirectionLeadingToTrailing, metrics: nil, views: ["v":v])
            self.view.addConstraints(constraint)
            self.view.addConstraints(vConstraint)
            }) { (finished) -> Void in
                fromViewController.removeFromParentViewController()
                toViewController.didMoveToParentViewController(self)
        }
    }

}
