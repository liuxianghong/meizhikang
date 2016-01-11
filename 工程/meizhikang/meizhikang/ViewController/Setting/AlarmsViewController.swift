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
    var soundID : SystemSoundID = 0
    var observer : NSObjectProtocol!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let strSoundFile = NSBundle.mainBundle().pathForResource("frog", ofType: "wav")
        let sample = NSURL(fileURLWithPath: strSoundFile!)
        let err = AudioServicesCreateSystemSoundID(sample, &soundID);
        observer = NSNotificationCenter.defaultCenter().addObserverForName("RingSwichOffNotification", object: nil, queue: NSOperationQueue.mainQueue()) { (notification : NSNotification) -> Void in
            self.timer.invalidate()
            self.timer = nil
            self.dismissViewControllerAnimated(true, completion: nil)
        }
        print(err)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.showSound()
        self.showSytemSound()
        self.timer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector:"cutDown" , userInfo: nil, repeats: true)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        self.timer.invalidate()
        NSNotificationCenter.defaultCenter().removeObserver(observer)
        BLEConnect.Instance().ternOffRing()
    }

    @IBAction func endClick(sender : UIButton){
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func cutDown(){
        timerCount--
        if timerCount == 0{
            self.timer.invalidate()
            //self.dismissViewControllerAnimated(true, completion: nil)
            return
        }
        self.timeLabel.text = NSString(format: "00:%02d", timerCount) as String
        self.showSound()
        if timerCount%6 == 0{
            self.showSytemSound()
        }
    }
    
    func showSound(){
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
    }
    
    func showSytemSound(){
        AudioServicesPlaySystemSound(soundID)
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
