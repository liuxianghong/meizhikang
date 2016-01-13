//
//  ChatImageViewController.swift
//  meizhikang
//
//  Created by shadowPriest on 16/1/13.
//  Copyright © 2016年 刘向宏. All rights reserved.
//

import UIKit

class ChatImageViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    var image: UIImage?
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        guard let image = self.image else{
            return
        }
        self.imageView.image = image
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func tapGesture(sender: UITapGestureRecognizer) {
        self.dismissViewControllerAnimated(false, completion: nil)
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
