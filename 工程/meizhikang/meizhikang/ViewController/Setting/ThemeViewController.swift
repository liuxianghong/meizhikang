//
//  ThemeViewController.swift
//  meizhikang
//
//  Created by 刘向宏 on 15/12/9.
//  Copyright © 2015年 刘向宏. All rights reserved.
//

import UIKit

class ThemeViewController: UIViewController {

    @IBOutlet weak var switchNatural : UISwitch!
    @IBOutlet weak var switchVitality : UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let theme = NSUserDefaults.standardUserDefaults().objectForKey("Theme") as? String
        if theme != nil && theme == "natural"{
            switchNatural.on = true
        }
        else{
            switchNatural.on = false
        }
        switchVitality.on = !switchNatural.on
    }

    @IBAction func vitalitychange(sender: UISwitch) {
        switchNatural.on = !switchVitality.on
        self.setTheme(switchNatural.on)
    }
    
    @IBAction func naturalchange(sender: UISwitch) {
        switchVitality.on = !switchNatural.on
        self.setTheme(switchNatural.on)
    }
    
    func setTheme(bo : Bool){
        if bo{
            NSUserDefaults.standardUserDefaults().setObject("natural", forKey: "Theme")
            
            UINavigationBar.appearance().barTintColor = UIColor.rgbColor(0x23debf)
        }
        else{
            NSUserDefaults.standardUserDefaults().setObject("vitality", forKey: "Theme")
            UINavigationBar.appearance().barTintColor = UIColor.rgbColor(0x5d51f4)
        }
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
