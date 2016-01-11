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
        
        timeButton1.selected = false
        selectedButton = timeButton1
        alarmSwitch.on = true
        if let user = UserInfo.CurrentUser(){
            if user.alarmTime == 0{
                alarmSwitch.on = false
            }
            else if user.alarmTime == 2*60{
                selectedButton = timeButton2
            }
            else if user.alarmTime == 3*60{
                selectedButton = timeButton3
            }
            else if user.alarmTime == 4*60{
                selectedButton = timeButton4
            }
            else if user.alarmTime == 5*60{
                selectedButton = timeButton5
            }
        }
        selectedButton.selected = true
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
        chageTime()
    }
    
    @IBAction func switchClick(sender : UISwitch?){
        BLEConnect.Instance().coloseRing(alarmSwitch.on)
        chageTime()
    }

    func chageTime(){
        if let user = UserInfo.CurrentUser(){
            if alarmSwitch.on{
                user.alarmTime = NSNumber(integer: selectedButton.tag * 60)
            }
            else{
                user.alarmTime = NSNumber(integer: 0)
            }
            NSManagedObjectContext.MR_defaultContext().MR_saveToPersistentStoreAndWait()
        }
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
