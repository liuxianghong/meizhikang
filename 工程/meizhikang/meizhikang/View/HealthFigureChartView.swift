//
//  HealthFigureChartView.swift
//  meizhikang
//
//  Created by 刘向宏 on 15/12/9.
//  Copyright © 2015年 刘向宏. All rights reserved.
//

import UIKit

@objc protocol HealthFigureChartViewDelegate{
    func showCurrentHealthData(health : HealthData);
}

class HealthFigureChartView: UIScrollView , UIScrollViewDelegate {

    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */
    
    var viewArray = [UIView]()
    var currentPoint : CGPoint!
    var first : Bool = true
    var dataArray = [HealthData]()
    weak var healthDelegate : HealthFigureChartViewDelegate!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.delegate = self
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        for (var i = viewArray.count; i<dataArray.count; i++){
            let view = UIView()
            view.tag = i
            view.layer.cornerRadius = 10;
            view.layer.masksToBounds = true;
            self.addSubview(view)
            viewArray.append(view)
        }
        for view in viewArray{
            view.backgroundColor = UIColor.helathColorByValue(dataArray[view.tag].healthValue as! Int)
            let height = self.frame.height * CGFloat(dataArray[view.tag].healthValue as! Int)/100
            view.frame = CGRect(x: self.frame.size.width - 70 + CGFloat.init((20+10) * view.tag), y: self.frame.height-height, width: 20, height: height)
        }
        if let lastView = viewArray.last{
            let last = (lastView.frame.origin.x) + (lastView.frame.size.width)
            self.contentSize = CGSize(width: last+50, height: self.frame.size.height)
        }
        
        
        if first{
            first = false
            currentPoint = CGPoint(x: self.contentSize.width, y: 0)
            self.contentOffset = currentPoint
        }
    }
    
    func appendData(data : HealthData){
        dataArray.append(data)
        self.layoutSubviews()
        currentPoint = CGPoint(x: self.contentSize.width - self.frame.size.width, y: 0)
        self.setContentOffset(currentPoint, animated: true)
        healthDelegate.showCurrentHealthData(dataArray.last!)
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        
    }
    
    func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        self.doScroll()
    }
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        self.doScroll()
    }
    
    func doScroll(){
        let f = self.contentOffset.x
        var ff = f%30
        if ff>15{
            ff = -(30-ff)
        }
        currentPoint = CGPoint(x: f-ff, y: 0)
        let tag = Int(currentPoint.x/30)
        print("\(tag)")
        self.setContentOffset(currentPoint, animated: true)
        if healthDelegate != nil{
            healthDelegate.showCurrentHealthData(dataArray[tag])
        }
    }
}
