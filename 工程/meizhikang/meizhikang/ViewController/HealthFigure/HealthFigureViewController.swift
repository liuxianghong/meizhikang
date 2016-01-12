//
//  HealthFigureViewController.swift
//  meizhikang
//
//  Created by 刘向宏 on 15/11/29.
//  Copyright © 2015年 刘向宏. All rights reserved.
//

import UIKit

class HealthFigureViewModel: NSObject{
    var headerTitles : [String]
    var currenTitle : String?
    override init(){
        self.headerTitles = ["4小时模式","1小时模式"]
    }
    
    func processTitles(nextTitle: String){
        self.headerTitles.removeObject(nextTitle)
        defer {
            currenTitle = nextTitle
        }
        guard let t = currenTitle else{
            return
        }
        self.headerTitles.append(t)
    }
}

class HealthFigureViewController: UIViewController ,UITableViewDataSource ,UITableViewDelegate ,HealthFigureChartViewDelegate ,BLEDataDelegate{

    @IBOutlet weak var headTableView: UITableView!
    @IBOutlet weak var headTableConstraint: NSLayoutConstraint!
    @IBOutlet weak var headerButton: UIButton!
    @IBOutlet weak var imageView1 : UIImageView!
    @IBOutlet weak var imageView2 : UIImageView!
    @IBOutlet weak var imageView3 : UIImageView!
    @IBOutlet weak var imageView4 : UIImageView!
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var queryButton: UIButton!
    @IBOutlet weak var chatView : HealthFigureChartView!
    @IBOutlet weak var scoreLabel : UILabel!
    @IBOutlet weak var heartRateLabel : UILabel!
    @IBOutlet weak var dateLabel : UILabel!
    @IBOutlet weak var timeLabel : UILabel!
    @IBOutlet weak var heartRateSwith : UISwitch!
    @IBOutlet weak var scoreStringLabel : UILabel!
    @IBOutlet weak var heartRateSwithLabel : UILabel!
    let tapGesture : UITapGestureRecognizer = UITapGestureRecognizer()
    let viewModel = HealthFigureViewModel()
    let tapView = UIView()
    var timer : NSTimer!
    var beforUser : User!
    var healthDataArray = [HealthData]()
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        if self.revealViewController() != nil{
            self.revealViewController().rearViewRevealWidth = 215
        }
        
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
        
        self.headerButton.setTitle("1小时模式", forState: .Normal)
        
        self.headTableConstraint.constant = -44
        self.headTableView.hidden = true
        self.headTableView.delegate = self
        self.tapGesture.addTarget(self, action: "gestureAction:")
        self.tapGesture.cancelsTouchesInView = false
        
        BLEConnect.Instance().dataDelegate = self
        heartRateLabel.text = ""
        
        tapView.frame = self.view.bounds
        self.view.addSubview(tapView)
        self.view.sendSubviewToBack(tapView)
        tapView.backgroundColor = UIColor.clearColor()
        
        chatView.healthDelegate = self
        self.showCurrentHealthData(nil)
        timer = NSTimer.scheduledTimerWithTimeInterval(60*5, target: self, selector: "cutDown", userInfo: nil, repeats: true)
        self.cutDown()
//        for _ in 1...30{
//            self.cutDown()
//        }
    }

    override func viewWillDisappear(animated: Bool) {
        self.headrCommand(false)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        self.headrCommand(heartRateSwith.on)
        if UserInfo.CurrentUser() != nil{
            if beforUser == nil{
                for hd in healthDataArray{
                    hd.user = UserInfo.CurrentUser()
                }
                healthDataArray.removeAll()
                NSManagedObjectContext.MR_defaultContext().MR_saveToPersistentStoreAndWait()
            }
            if beforUser != UserInfo.CurrentUser(){
                chatView.clear()
                let healthData = UserInfo.CurrentUser()?.healthDatasOneDay(NSDate())
                for hdata in healthData!{
                    chatView.appendData(hdata)
                }
            }
            beforUser = UserInfo.CurrentUser()
            
            #if DEBUG
            if UserInfo.CurrentUser()?.healthDatas?.count <= 100{
                let timeInterval = NSDate().timeIntervalSince1970
                for index in 1...1000{
                    let date = NSDate(timeIntervalSince1970: timeInterval - Double(index*60*5))
                    let healthData = HealthData.MR_createEntity()
                    healthData.time = date
                    healthData.heartRate = 60 + Int((healthData.time?.timeIntervalSince1970)!) % 70
                    healthData.healthValue = 20 + Int((healthData.time?.timeIntervalSince1970)!) % 80
                    healthData.user = UserInfo.CurrentUser()
                }
                NSManagedObjectContext.MR_defaultContext().MR_saveToPersistentStoreAndWait()
            }
            else{
                
            }
            #endif
        }
        else{
            if beforUser != nil{
                chatView.clear()
            }
            beforUser = nil
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
    
    @IBAction func didHearCommandClick(){
        heartRateSwithLabel.hidden = !heartRateSwith.on
        heartRateLabel.hidden = !heartRateSwith.on
        self.headrCommand(heartRateSwith.on)
    }
    
    func headrCommand(bo : Bool){
        BLEConnect.Instance().setHeartCommand(bo ? 3600 : 0)
    }
    
    func didUpdateHartValue(value: Int) {
        heartRateLabel.text = "\(value)"
    }
    
    func didUpdateHealthValue(value: Int, date: NSDate!) {
        let healthData = HealthData.MR_createEntity()
        healthData.time = date
        healthData.heartRate = 0
        healthData.healthValue = value
        if UserInfo.CurrentUser() == nil{
            healthDataArray.append(healthData)
        }
        else
        {
            healthData.user = UserInfo.CurrentUser()
            NSManagedObjectContext.MR_defaultContext().MR_saveToPersistentStoreAndWait()
        }
        
        chatView.appendData(healthData)
    }
    
    
    func cutDown(){
        #if DEBUG
        //self.didUpdateHealthValue(60, date: NSDate())
        #endif
        self.didHearCommandClick()
    }
    
    func showCurrentHealthData(health : HealthData?){
        if health != nil{
            scoreLabel.text = "\(health!.healthValue as! Int)"
            scoreLabel.textColor = UIColor.helathColorByValue(health!.healthValue as! Int)
            scoreStringLabel.textColor = UIColor.helathColorByValue(health!.healthValue as! Int)
            scoreStringLabel.text = health?.helathString()
            let formatter = NSDateFormatter()
            formatter.dateFormat = "yyyy.MM.dd"
            dateLabel.text = formatter.stringFromDate(health!.time!)
            formatter.dateFormat = "HH:mm"
            timeLabel.text = formatter.stringFromDate(health!.time!)
        }
        else{
            scoreLabel.text = " "
            dateLabel.text = " "
            timeLabel.text = " "
            scoreStringLabel.text = " "
        }
    }
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(HealthReportConstant.HeaderCellIdentifier, forIndexPath: indexPath) as! HealthReportHeaderTableViewCell
        cell.contentLabel.text = self.viewModel.headerTitles[indexPath.row]
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        self.viewModel.processTitles(self.viewModel.headerTitles[indexPath.row])
        self.headerButton.setTitle(self.viewModel.currenTitle, forState: .Normal)
        UIView.animateWithDuration(0.5) { () -> Void in
            self.chatView.type = self.viewModel.currenTitle == "1小时模式" ? 1 : 2
        }
        headerShow(false)
    }
    
    @IBAction func titleClicked(sender: UIButton) {
        //        self.containerViewController?.performSegueWithIdentifier(HealthReportContainerConstant.WeeklySegueIdentifier, sender: nil)
        headerShow(self.headTableView.hidden)
    }
    
    func headerShow(flag: Bool){
        if self.headTableView.hidden != flag {
            return
        }
        let delay = 0.5
        if flag {
            self.headTableView.hidden = false
            self.headTableConstraint.constant = 0
            self.view.setNeedsUpdateConstraints()
            UIView.animateWithDuration(delay, animations: { () -> Void in
                self.view.layoutIfNeeded()
                }, completion: { finished in
                    self.headTableView.reloadData()
                    self.tapView.addGestureRecognizer(self.tapGesture)
            })
        }else{
            self.headTableConstraint.constant = -44
            self.view.setNeedsUpdateConstraints()
            UIView.animateWithDuration(delay, animations: {
                self.view.layoutIfNeeded()
                }, completion: { finished in
                    self.headTableView.hidden = true
                    self.headTableView.reloadData()
                    self.tapView.removeGestureRecognizer(self.tapGesture)
            })
        }
    }
    
    func gestureAction(gesture: UITapGestureRecognizer){
        headerShow(false)
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if self.revealViewController() != nil{
            self.revealViewController().setFrontViewPosition(.Left, animated: true)
        }
    }


}
