//
//  HealthFigureChartView.swift
//  meizhikang
//
//  Created by 刘向宏 on 15/12/9.
//  Copyright © 2015年 刘向宏. All rights reserved.
//

import UIKit

protocol HealthFigureChartViewDelegate:class{
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
    
    var viewArray = [RectView]()
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
            let position = CGFloat(positionDate.timeIntervalSinceDate(date))
            let pos2 = (position) / CGFloat(24*60*60) + 1
            let point = CGPoint(x: pos2 * (cwidth - rightMargin - fwidth), y: 0)
            self.setContentOffset(point, animated: false)
        }
    }
    var date : NSDate!
    let leftMargin : CGFloat = 15
    let rightMargin : CGFloat = 60
    //var position: CGFloat = 1
    var positionDate = NSDate()
    var timeOffer : CGFloat = 0
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.delegate = self
        for index in 0...48{
            let timeLabel = UILabel()
            timeLabel.font = UIFont.systemFontOfSize(8)
            let view = UIView()
            view.backgroundColor = UIColor.lightGrayColor()
            timeViewArray.append(HealthFigureChartTimeView(timeLabel: timeLabel, view: view ,tag: index))
            self.addSubview(timeLabel)
            self.addSubview(view)
        }
        setDateEnd(NSDate())
    }
    
    func configTimeView(){
        let hour = NSCalendar.currentCalendar().component(.Hour, fromDate: date)
        let minute = NSCalendar.currentCalendar().component(.Minute, fromDate: date)
        let second = NSCalendar.currentCalendar().component(.Second, fromDate: date)
        var minuteTag : Int
        if minute >= 30{
            minuteTag = 1
            timeOffer = CGFloat(minute - 30)/(24*60) + CGFloat(second)/(24*60*60)
        }
        else{
            minuteTag = 0
            timeOffer = CGFloat(minute)/(24*60) + CGFloat(second)/(24*60*60)
        }
        for timeView in timeViewArray{
            let minuteValue = (minuteTag + timeView.tag)%2*30
            var hourValue = hour
            if minuteTag == 1{
                hourValue = hour - (48 - timeView.tag )/2
            }
            else{
                hourValue = hour - (48 - timeView.tag + 1)/2
            }
            if hourValue < 0{
                hourValue = 24 + hourValue
            }
            timeView.view.tag = (minuteTag + timeView.tag)%2
            timeView.timeLabel.text = NSString(format: "%02d:%02d", hourValue,minuteValue) as String
            timeView.timeLabel.sizeToFit()
        }
        
        
        
        var rearray = [HealthFigureChartViewModel]()
        for lineData2 in dataArray{
            if CGFloat((lineData2.healthData.time?.timeIntervalSinceDate(date))!)  > -24*60*60{
                let pos = CGFloat((lineData2.healthData.time?.timeIntervalSinceDate(date))!)
                let pos2 = (pos) / CGFloat(24*60*60) + 1
                let lineData3 = HealthFigureChartViewModel(position: pos2, value: lineData2.value, healthData: lineData2.healthData)
                rearray.append(lineData3)
            }
        }
        dataArray = rearray
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if first{
            self.updateContentSize()
            first = false
            self.setContentOffset(CGPointMake((cwidth - rightMargin - fwidth), 0), animated: false)
            doScroll()
            positionDate = date
        }
    }
    
    func updateContentSize() {
        fwidth = self.frame.size.width - rightMargin
        twidth = 0
        cwidth = 0
        if type == 1{
            cwidth = fwidth*24+rightMargin+fwidth
            twidth = fwidth/2
            chartWidth = fwidth/12
            space = 6
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
            let view = RectView()
            view.tag = i
            view.layer.masksToBounds = true;
            self.addSubview(view)
            viewArray.append(view)
        }
        
        for timeView in timeViewArray{
            let width = timeView.timeLabel.frame.size.width
            let heght : CGFloat = 15
            timeView.timeLabel.frame = CGRectMake(fwidth + twidth * CGFloat(timeView.tag) - width/2 - timeOffer*(cwidth - rightMargin - fwidth), self.contentSize.height - heght, width, heght)
            timeView.view.frame = CGRectMake(timeView.timeLabel.frame.origin.x+width/2, timeView.timeLabel.frame.origin.y-8, 1, 8)
            timeView.view.hidden = false
            timeView.timeLabel.hidden = false
            if self.type == 1{
                
            }else {
                if timeView.view.tag == 1{
                    timeView.view.hidden = true
                    timeView.timeLabel.hidden = true
                }
            }
            
        }
        
        for view in viewArray{
            if dataArray.count > view.tag{
                let sheight = self.frame.height - (15 + 10)
                let hdata = dataArray[view.tag]
                view.backgroundColor = UIColor.helathColorByValue(hdata.value)
                let height = sheight * CGFloat(hdata.value)/100
                view.frame = CGRect(x: fwidth + (cwidth - rightMargin - fwidth) * hdata.position - (chartWidth - space) , y: sheight-height, width: chartWidth-space, height: height)
                view.layer.cornerRadius = (chartWidth-space)/2;
            }
            else{
                view.removeFromSuperview()
            }
        }
    }
    
    func setDateEnd(ndate : NSDate){
        date = ndate
        configTimeView()
    }
    
    func appendData(data : HealthData){
        
        var pos = CGFloat((data.time?.timeIntervalSinceDate(date))!)
        if pos < -24*60*60{
            return
        }
        if pos > 0{
            setDateEnd(data.time!)
            pos = CGFloat((data.time?.timeIntervalSinceDate(date))!)
        }
        let v = Int(data.healthValue!)
        let pos2 = (pos) / CGFloat(24*60*60) + 1
        let lineData = HealthFigureChartViewModel(position:  pos2, value: v, healthData: data)
        
        var doSroll = false
        if dataArray.isEmpty{
            let cpos = self.contentOffset.x / (cwidth - rightMargin - fwidth)
            if (cpos <= pos2)
            {
                doSroll = true
            }
        }
        else {
            let cpos = self.contentOffset.x / (cwidth - rightMargin - fwidth)
            if ( cpos >= dataArray.last?.position && cpos <= pos2)
            {
                doSroll = true
            }
        }
        
        dataArray.append(lineData)
        self.layoutAllViews()
        if doSroll{
            let point = CGPoint(x: lineData.position * (cwidth - rightMargin - fwidth), y: 0)
            self.setContentOffset(point, animated: true)
            positionDate = data.time!
            healthDelegate.showCurrentHealthData(lineData.healthData)
        }
        else{
            var position = CGFloat(positionDate.timeIntervalSinceDate(date))
            if position < -24*60*60{
                position = -24*60*60
                positionDate = date.dateByAddingTimeInterval(NSTimeInterval(position))
            }
            let pos3 = (position) / CGFloat(24*60*60) + 1
            let point = CGPoint(x: pos3 * (cwidth - rightMargin - fwidth), y: 0)
            self.setContentOffset(point, animated: false)
        }
    }
    
    
    func clear(){
        dataArray.removeAll()
        for view in viewArray{
            view.removeFromSuperview()
        }
        viewArray.removeAll()
        let point = CGPoint(x: (cwidth - rightMargin - fwidth), y: 0)
        self.setContentOffset(point, animated: true)
        positionDate = date;
    }
    
    
    func zeroOfDate(date : NSDate) -> NSDate?{
        return NSCalendar.currentCalendar().dateBySettingHour(0, minute: 0, second: 0, ofDate: date, options: NSCalendarOptions(rawValue: 0))
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
        let pos2d5 : CGFloat = 4*60 / ( 60 * 60 * 24)
        //* (cwidth - rightMargin - fwidth)
        let posCurrnt = f / (cwidth - rightMargin - fwidth)
        for vm in dataArray{
            let posd = posCurrnt - vm.position
            if posd <= pos2d5/4 && posd >= -pos2d5{
                let point = CGPoint(x: vm.position * (cwidth - rightMargin - fwidth), y: 0)
                self.setContentOffset(point, animated: true)
                positionDate = vm.healthData.time!
                if healthDelegate != nil{
                    healthDelegate.showCurrentHealthData(vm.healthData)
                }
                return
            }
        }
        healthDelegate.showCurrentHealthData(nil)
        positionDate = date.dateByAddingTimeInterval(NSTimeInterval((posCurrnt-1)*(24*60*60)))
    }
}
