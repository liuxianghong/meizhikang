//
//  AlarmViewController.swift
//  meizhikang
//
//  Created by 刘向宏 on 15/12/1.
//  Copyright © 2015年 刘向宏. All rights reserved.
//

import UIKit

class AlarmViewController: UIViewController {

    @IBOutlet weak var alarmSwitch : UISwitch!
    
    @IBOutlet weak var timeButton1 : UIButton!
    @IBOutlet weak var timeButton2 : UIButton!
    @IBOutlet weak var timeButton3 : UIButton!
    @IBOutlet weak var timeButton4 : UIButton!
    @IBOutlet weak var timeButton5 : UIButton!
    
    var selectedButton : UIButton! = nil
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.buttonClic(timeButton1)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func buttonClic(sender : UIButton){
        if selectedButton != nil{
            selectedButton.selected = false
        }
        sender.selected = true
        selectedButton = sender
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
