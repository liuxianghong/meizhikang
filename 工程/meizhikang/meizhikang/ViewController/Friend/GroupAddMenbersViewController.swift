//
//  GroupAddMenbersViewController.swift
//  meizhikang
//
//  Created by 刘向宏 on 16/1/13.
//  Copyright © 2016年 刘向宏. All rights reserved.
//

import UIKit

class GroupAddMenbersViewController: UIViewController , UITextFieldDelegate {

    var group : Group?
    var type = 1
    @IBOutlet weak var field1 : UITextField!
    @IBOutlet weak var field2 : UITextField!
    @IBOutlet weak var view2 : UIView!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        if type != 1{
            self.title = "查找群组"
            view2.hidden = true
            field2.hidden = true
            field1.keyboardType = .Default
            field1.placeholder = "请输入待查找群组的名称"
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func okClick(sender : AnyObject?){
    }

    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
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
