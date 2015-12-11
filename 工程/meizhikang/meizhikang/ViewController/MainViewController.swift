//
//  MainViewController.swift
//  meizhikang
//
//  Created by 刘向宏 on 15/11/29.
//  Copyright © 2015年 刘向宏. All rights reserved.
//

import UIKit

class MainViewController: UINavigationController {

    var first : Bool = true
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        if first{
            first = false
            self.performSegueWithIdentifier("loginIdentifier", sender: nil)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
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
