//
//  HealthFigureChartView.swift
//  meizhikang
//
//  Created by 刘向宏 on 15/12/9.
//  Copyright © 2015年 刘向宏. All rights reserved.
//

import UIKit

class HealthFigureChartView: UIScrollView , UIScrollViewDelegate {

    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */
    
    var viewArray : [UIView] = [UIView()]
    var currentPoint : CGPoint!
    var first : Bool = true
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.delegate = self
        for (var i = 0; i<15; i++){
            let view = UIView()
            view.tag = i
            view.layer.cornerRadius = 10;
            view.layer.masksToBounds = true;
            self.addSubview(view)
            viewArray.append(view)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        for view in viewArray{
            view.backgroundColor = UIColor.greenColor()
            let height = self.frame.height - CGFloat(view.tag*10)
            view.frame = CGRect(x: self.frame.size.width - 70 + CGFloat.init((20+10) * view.tag), y: self.frame.height-height, width: 20, height: height)
        }
        let lastView = viewArray.last
        let last = (lastView?.frame.origin.x)! + (lastView?.frame.size.width)!
        self.contentSize = CGSize(width: last+50, height: self.frame.size.height)
        if first{
            first = false
            currentPoint = CGPoint(x: self.contentSize.width, y: 0)
            self.contentOffset = currentPoint
        }
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
        self .setContentOffset(currentPoint, animated: true)
    }
}
