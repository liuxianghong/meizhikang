//
//  ResetPWViewController.swift
//  meizhikang
//
//  Created by 刘向宏 on 15/12/16.
//  Copyright © 2015年 刘向宏. All rights reserved.
//

import UIKit
import MBProgressHUD

class ResetPWViewController: UIViewController {

    @IBOutlet weak var stepLabel : UILabel!
    @IBOutlet weak var textField1 : UITextField!
    @IBOutlet weak var textField2 : UITextField!
    @IBOutlet weak var itemButton : UIBarButtonItem!
    @IBOutlet weak var imageView : UIImageView!
    @IBOutlet weak var reflushButton : UIButton!
    var userName = ""
    var step = 1
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.textField2.hidden = true
        self.reflushButton.hidden = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func reflushButtonClick(){
        
        let hud = MBProgressHUD.showHUDAddedTo(self.view.window, animated: true)
        IMRequst.getResetPWToken(userName, completion: { (token : NSData!, data : NSData!) -> Void in
            let image = UIImage(data: data);
            self.imageView.image = image;
            hud.hide(true)
            }) { (error : NSError!) -> Void in
                hud.mode = .Text
                hud.detailsLabelText = error.domain;
                hud.hide(true, afterDelay: 1.5)
                print(error)
        }
        
        
        
        
    }

    @IBAction func stepClick(){
        if step == 1{
            let hud = MBProgressHUD.showHUDAddedTo(self.view.window, animated: true)
            if !self.textField1.text!.checkTel(){
                hud.mode = .Text
                hud.detailsLabelText = "请输入正确的手机号"
                hud.hide(true, afterDelay: 1.5)
                return;
            }
            userName = self.textField1.text!
            IMRequst.getResetPWToken(self.textField1.text, completion: { (token : NSData!, data : NSData!) -> Void in
                print(data)
                let image = UIImage(data: data);
                self.textField1.text = ""
                self.textField1.resignFirstResponder()
                self.textField1.placeholder = "请输入上方的验证码"
                self.textField1.keyboardType = .ASCIICapable
                self.stepLabel.text = "重置密码共三步，当前为第二步"
                self.imageView.image = image;
                self.step++
                self.reflushButton.hidden = false
                hud.hide(true)
                }) { (error : NSError!) -> Void in
                    hud.mode = .Text
                    hud.detailsLabelText = error.domain;
                    hud.hide(true, afterDelay: 1.5)
                    print(error)
            }
        }
        else if step == 2{
            let hud = MBProgressHUD.showHUDAddedTo(self.view.window, animated: true)
            
            if self.textField1.text!.isEmpty{
                hud.mode = .Text
                hud.detailsLabelText = "请输入验证码"
                hud.hide(true, afterDelay: 1.5)
                return;
            }
            
            IMRequst.getCode(userName, code: self.textField1.text, completion: { (data : NSData!, Int32) -> Void in
                
                }, failure: { (error : NSError!) -> Void in
                    hud.mode = .Text
                    hud.detailsLabelText = error.domain;
                    hud.hide(true, afterDelay: 1.5)
                    print(error)
            })
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
