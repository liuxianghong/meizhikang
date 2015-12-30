//
//  HealthReportViewController.swift
//  meizhikang
//
//  Created by shadowPriest on 15/12/2.
//  Copyright © 2015年 刘向宏. All rights reserved.
//

import UIKit

struct HealthReportConstant{
    static let EmbededSegueIdentifier = "EmbededIdentifier"
    static let HeaderCellIdentifier = "HeaderCellIdentifier"
}

class HealthReportViewModel: NSObject{
    var date : NSDate
    var headerTitles : [String]
    var currenTitle : String?
    var containerIdentifier = HealthReportContainerConstant.DailySegueIdentifier
    init(date: NSDate){
        self.date = date
        self.headerTitles = ["健康日报","健康周报","健康月报"]
    }
    
    func processTitles(nextTitle: String){
        self.headerTitles.removeObject(nextTitle)
        defer {
            currenTitle = nextTitle
            if nextTitle == "健康日报"{
                self.containerIdentifier = HealthReportContainerConstant.DailySegueIdentifier
            }else{
                self.containerIdentifier = HealthReportContainerConstant.WeeklySegueIdentifier
            }
        }
        guard let t = currenTitle else{
            return
        }
        self.headerTitles.append(t)
    }
}

class HealthReportViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {
    
    @IBOutlet weak var headTableView: UITableView!
    @IBOutlet weak var headTableConstraint: NSLayoutConstraint!
    @IBOutlet weak var headerButton: UIButton!
    let tapGesture : UITapGestureRecognizer = UITapGestureRecognizer()
    weak var containerViewController : HealthReportContainerViewController?
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
        self.viewModel.processTitles((self.headerButton.titleLabel?.text)!)
        self.headTableConstraint.constant = -88
        self.headTableView.hidden = true
        self.tapGesture.addTarget(self, action: "gestureAction:")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
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
        if self.viewModel.currenTitle == "健康周报"{
            self.containerViewController?.weekType = .Week
        }else{
            self.containerViewController?.weekType = .Month
        }
        self.containerViewController?.performSegueWithIdentifier(self.viewModel.containerIdentifier, sender: nil)
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
                    self.containerViewController?.view.addGestureRecognizer(self.tapGesture)
            })
        }else{
            self.headTableConstraint.constant = -88
            self.view.setNeedsUpdateConstraints()
            UIView.animateWithDuration(delay, animations: {
                self.view.layoutIfNeeded()
                }, completion: { finished in
                    self.headTableView.hidden = true
                    self.headTableView.reloadData()
                    self.containerViewController?.view.removeGestureRecognizer(self.tapGesture)
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
        if (segue.identifier == HealthReportConstant.EmbededSegueIdentifier){
            self.containerViewController = segue.destinationViewController as? HealthReportContainerViewController
            self.containerViewController?.date = self.viewModel.date
        }
    }

}
