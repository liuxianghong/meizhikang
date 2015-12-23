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
        self.headerTitles = [" 4小时模式","30分钟模式"]
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

class HealthFigureViewController: UIViewController ,UITableViewDataSource ,UITableViewDelegate {

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
    let tapGesture : UITapGestureRecognizer = UITapGestureRecognizer()
    let viewModel = HealthFigureViewModel()
    let tapView = UIView()
    var timer : NSTimer!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        if self.revealViewController() != nil{
            self.revealViewController().rearViewRevealWidth = 215
        }
        
        self.headTableConstraint.constant = -44
        self.headTableView.hidden = true
        self.headTableView.delegate = self
        self.tapGesture.addTarget(self, action: "gestureAction:")
        self.tapGesture.cancelsTouchesInView = false
        
        
        tapView.frame = self.view.bounds
        self.view.addSubview(tapView)
        self.view.sendSubviewToBack(tapView)
        tapView.backgroundColor = UIColor.clearColor()
        
        
        timer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: "cutDown", userInfo: nil, repeats: true)
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        if UserInfo.CurrentUser() != nil{
            if UserInfo.CurrentUser()?.healthDatas?.count == 0{
                let timeInterval = NSDate().timeIntervalSince1970
                for index in 1...10000{
                    let date = NSDate(timeIntervalSince1970: timeInterval - Double(index*60*5))
                    let healthData = HealthData.MR_createEntity()
                    healthData.time = date
                    healthData.heartRate = 60 + Int((healthData.time?.timeIntervalSince1970)!) % 70
                    healthData.healthValue = 20 + Int((healthData.time?.timeIntervalSince1970)!) % 80
                    healthData.user = UserInfo.CurrentUser()
                }
                NSManagedObjectContext.MR_defaultContext().MR_saveToPersistentStoreAndWait()
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
    
    
    func cutDown(){
        let healthData = HealthData.MR_createEntity()
        healthData.time = NSDate()
        healthData.heartRate = 60 + Int((healthData.time?.timeIntervalSince1970)!) % 70
        healthData.healthValue = 20 + Int((healthData.time?.timeIntervalSince1970)!) % 80
        healthData.user = UserInfo.CurrentUser()
        NSManagedObjectContext.MR_defaultContext().MR_saveToPersistentStoreAndWait()
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
