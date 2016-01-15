//
//  HealthComDiseasesViewController.swift
//  meizhikang
//
//  Created by 刘向宏 on 15/12/23.
//  Copyright © 2015年 刘向宏. All rights reserved.
//

import UIKit

class HealthComDiseasesViewController: UIViewController {

    @IBOutlet weak var scrollView : UIScrollView!
    @IBOutlet weak var webView : UIWebView!
    var viewArray = [UIImageView]()
    @IBOutlet weak var scrollView2 : UIScrollView!
    @IBOutlet weak var imageView : UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.webView.loadHTMLString("", baseURL: nil)
        self.webView.scrollView.showsHorizontalScrollIndicator = false
        for index in 1...10 {
            print("\(index) times 5 is \(index * 5)")
            let view = UIImageView(image: UIImage(named: "矢量智能对象\(index)"))
            view.tag = index
            view.sizeToFit()
            view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "tapGestureClick:"))
            view.userInteractionEnabled = true
            scrollView.addSubview(view)
            viewArray.append(view)
        }
        
        imageView.image = UIImage(named: "疾病图1")
        let baseURL = NSURL.fileURLWithPath(NSBundle.mainBundle().bundlePath)
        let path = NSBundle.mainBundle().pathForResource("html1", ofType: "html")
        do{
            let html = try NSString(contentsOfFile: path!, encoding: NSUTF8StringEncoding)
            webView.loadHTMLString(html as String, baseURL: baseURL)
        }catch let error as NSError {
            print(error.localizedDescription)
        }
        self.webView.backgroundColor = UIColor.whiteColor()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        for view in viewArray{
            view.frame = CGRectMake((20+view.frame.size.width)*(CGFloat(view.tag-1)), (scrollView.frame.size.height - view.frame.size.height)/2, view.frame.size.width, view.frame.size.height)
        }
        scrollView.contentSize = CGSizeMake(((viewArray.last?.frame.size.width)!+20)*(CGFloat(viewArray.count)) + 20, scrollView.frame.size.height)
    }
    
    func tapGestureClick(tapGesture : UITapGestureRecognizer){
        
        let baseURL = NSURL.fileURLWithPath(NSBundle.mainBundle().bundlePath)
        imageView.image = UIImage(named: "疾病图\(tapGesture.view!.tag)")
        scrollView2.setContentOffset(CGPointMake(0, 0), animated: false)
        print(tapGesture.view?.tag)
        let path = NSBundle.mainBundle().pathForResource("html\(tapGesture.view!.tag)", ofType: "html")
        do{
            let html = try NSString(contentsOfFile: path!, encoding: NSUTF8StringEncoding)
            webView.loadHTMLString(html as String, baseURL: baseURL)
        }catch let error as NSError {
            print(error.localizedDescription)
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
