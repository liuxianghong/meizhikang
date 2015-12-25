//
//  HealthFigureChartView.swift
//  meizhikang
//
//  Created by 刘向宏 on 15/12/9.
//  Copyright © 2015年 刘向宏. All rights reserved.
//

import UIKit

@objc protocol HealthFigureChartViewDelegate{
    func showCurrentHealthData(health : HealthData?);
}


struct HealthFigureChartViewModel{
    var position: CGFloat
    var value: NSInteger
    var healthData : HealthData
}

struct HealthFigureChartTimeView{
    var timeLabel : UILabel
    var view : UIView
    var tag : Int
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
    var timeViewArray = [HealthFigureChartTimeView]()
    var currentPoint : CGPoint!
    var first : Bool = true
    var dataArray = [HealthFigureChartViewModel]()
    var chartWidth : CGFloat = 0
    var space : CGFloat = 0
    var fwidth : CGFloat = 0
    var twidth : CGFloat  = 0
    var cwidth : CGFloat = 0
    weak var healthDelegate : HealthFigureChartViewDelegate!
    var type : Int = 1{
        didSet{
            self.updateContentSize()
            let point = CGPoint(x: position * (cwidth - rightMargin - fwidth), y: 0)
            self.setContentOffset(point, animated: false)
        }
    }
    var date = NSDate()
    let leftMargin : CGFloat = 15
    let rightMargin : CGFloat = 60
    var position: CGFloat = 0
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.delegate = self
        for index in 0...48{
            let timeLabel = UILabel()
            timeLabel.text = NSString(format: "%02d:%02d", index/2,index%2*30) as String
            timeLabel.font = UIFont.systemFontOfSize(8)
            timeLabel.sizeToFit()
            let view = UIView()
            view.backgroundColor = UIColor.lightGrayColor()
            timeViewArray.append(HealthFigureChartTimeView(timeLabel: timeLabel, view: view ,tag: index))
            self.addSubview(timeLabel)
            self.addSubview(view)
        }
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if first{
            self.updateContentSize()
            first = false
        }
    }
    
    func updateContentSize() {
        fwidth = self.frame.size.width - rightMargin
        twidth = 0
        cwidth = 0
        if type == 1{
            cwidth = fwidth*48+rightMargin+fwidth
            twidth = fwidth
            chartWidth = fwidth/6
            space = 10
        }
        else{
            cwidth = fwidth*6+rightMargin+fwidth
            chartWidth = fwidth/48
            space = 2
            twidth = fwidth/8
        }
        self.contentSize = CGSize(width: cwidth, height: self.frame.size.height)
        self.layoutAllViews()
    }
    
    func layoutAllViews(){
        for (var i = viewArray.count; i<dataArray.count; i++){
            let view = UIView()
            view.tag = i
            view.layer.masksToBounds = true;
            self.addSubview(view)
            viewArray.append(view)
        }
        
        for timeView in timeViewArray{
            let width = timeView.timeLabel.frame.size.width
            let heght : CGFloat = 15
            timeView.timeLabel.frame = CGRectMake(fwidth + twidth * CGFloat(timeView.tag) - width/2, self.contentSize.height - heght, width, heght)
            timeView.view.frame = CGRectMake(timeView.timeLabel.frame.origin.x+width/2, timeView.timeLabel.frame.origin.y-8, 1, 8)
        }
        
        for view in viewArray{
            let sheight = self.frame.height - (15 + 10)
            let hdata = dataArray[view.tag]
            view.backgroundColor = UIColor.helathColorByValue(hdata.value)
            let height = sheight * CGFloat(hdata.value)/100
            view.frame = CGRect(x: fwidth + (cwidth - rightMargin - fwidth) * hdata.position - (chartWidth - space)/2 , y: sheight-height, width: chartWidth-space, height: height)
            view.layer.cornerRadius = (chartWidth-space)/2;
        }
    }
    
    func appendData(data : HealthData){
        
        var pos = CGFloat((data.time?.timeIntervalSinceDate(self.zeroOfDate(date)!))!)
        let v = Int(data.healthValue!)
        var pos2 = (pos + CGFloat(5*60*dataArray.count)) / CGFloat(24*60*60)
        if pos2 > 1{
            dataArray.removeAll()
            date = NSDate()
            pos = CGFloat((data.time?.timeIntervalSinceDate(self.zeroOfDate(date)!))!)
            pos2 = (pos + CGFloat(5*60*dataArray.count)) / CGFloat(24*60*60)
        }
        let lineData = HealthFigureChartViewModel(position:  pos2, value: v, healthData: data)
        dataArray.append(lineData)
        self.layoutAllViews()
        self.doScroll()
    }
    
    
    func zeroOfDate(data : NSDate) -> NSDate?{
        let formatter = NSDateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let fstr = formatter.stringFromDate(data)
        let zeroDate = "\(fstr) 00:00:00"
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return formatter.dateFromString(zeroDate)
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
        let pos2d5 : CGFloat = 2.5*60 / ( 60 * 60 * 24)
        //* (cwidth - rightMargin - fwidth)
        let posCurrnt = f / (cwidth - rightMargin - fwidth)
        for vm in dataArray{
            let posd = posCurrnt - vm.position
            if posd <= pos2d5 && posd >= -pos2d5{
                let point = CGPoint(x: vm.position * (cwidth - rightMargin - fwidth), y: 0)
                self.setContentOffset(point, animated: true)
                position = vm.position
                if healthDelegate != nil{
                    healthDelegate.showCurrentHealthData(vm.healthData)
                }
                return
            }
        }
        healthDelegate.showCurrentHealthData(nil)
        position = posCurrnt
    }
}
