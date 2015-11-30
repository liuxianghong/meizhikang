//
//  AlertViewController.swift
//  meizhikang
//
//  Created by 刘向宏 on 15/11/30.
//  Copyright © 2015年 刘向宏. All rights reserved.
//

import UIKit

protocol AlartViewControllerDelegate{
    func didClickButton(index:Int, tag:Int)
}

class AlertViewController: UIViewController {

    @IBOutlet weak var titleLabel : UILabel!
    @IBOutlet weak var messgaeLabel : UILabel!
    var delegate : AlartViewControllerDelegate?
    var tag:Int = 0
    var titleText:String! = ""
    var messageText:String! = ""
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.titleLabel.text = self.titleText
        self.messgaeLabel.text = self.messageText
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func okClick(sender : AnyObject) {
        dismissViewControllerAnimated(false) { () -> Void in
            self.delegate?.didClickButton(1, tag: self.tag)
        }
    }
    
    @IBAction func cancelClick(sender : AnyObject) {
        dismissViewControllerAnimated(false) { () -> Void in
            self.delegate?.didClickButton(0, tag: self.tag)
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
