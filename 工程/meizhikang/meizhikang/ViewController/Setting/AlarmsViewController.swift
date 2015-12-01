//
//  AlarmsViewController.swift
//  meizhikang
//
//  Created by 刘向宏 on 15/12/1.
//  Copyright © 2015年 刘向宏. All rights reserved.
//

import UIKit
import AudioToolbox

class AlarmsViewController: UIViewController {

    @IBOutlet weak var typeLabel : UILabel!
    @IBOutlet weak var timeLabel : UILabel!
    @IBOutlet weak var endButton : UIButton!
    var timer : NSTimer!
    var timerCount =  60
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.showSound()
        self.timer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector:"cutDown" , userInfo: nil, repeats: true)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        self.timer.invalidate()
    }

    @IBAction func endClick(sender : UIButton){
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    func cutDown(){
        timerCount--
        if timerCount == 0{
            self.timer.invalidate()
        }
        self.timeLabel.text = NSString(format: "00:%02d", timerCount) as String
        self.showSound()
    }
    
    func showSound(){
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
        AudioServicesPlaySystemSound(1012);
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
