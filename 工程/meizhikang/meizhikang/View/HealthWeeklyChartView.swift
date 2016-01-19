//
//  HealthWeeklyChartView.swift
//  meizhikang
//
//  Created by shadowPriest on 15/12/28.
//  Copyright © 2015年 刘向宏. All rights reserved.
//

import UIKit

class HealthWeeklyChartView: UIView {

    @IBOutlet weak var date1: UILabel!
    var chartData: [WeeklyViewLineData]?
    var minValue: CGFloat = 100
    var maxValue: CGFloat = 0
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    func drawCoordinate(rect: CGRect){
        let step = Int((maxValue - minValue) / 10)
        let context = UIGraphicsGetCurrentContext()
        CGContextSetLineWidth(context, 1.0)
        for i in 0...step{
            let attr = [NSFontAttributeName : UIFont.systemFontOfSize(10),
                NSForegroundColorAttributeName : UIColor.whiteColor()]
            let str = NSAttributedString(string: "\(i * 10 + Int(minValue))", attributes: attr)
            let strPoint = CGPointMake(8,(rect.size.height - 10) - (rect.size.height - 10) * CGFloat(i) / CGFloat(step))
            str.drawAtPoint(strPoint)
            CGContextBeginPath(context)
            CGContextSetStrokeColorWithColor(context, UIColor.whiteColor().CGColor)
            let currentPoint = CGPointMake(25, 1 + (rect.size.height - 2) - (rect.size.height - 2) * CGFloat(i) / CGFloat(step))
            CGContextMoveToPoint(context, currentPoint.x, currentPoint.y)
            CGContextAddLineToPoint(context, currentPoint.x + 8, currentPoint.y)
            if i < step {
                let nextPoint = CGPointMake(25, 1 + (rect.size.height - 2) - (rect.size.height - 2) * CGFloat(i + 1) / CGFloat(step))
                CGContextMoveToPoint(context, currentPoint.x, currentPoint.y)
                CGContextAddLineToPoint(context, nextPoint.x, nextPoint.y)
            }
            CGContextStrokePath(context)
        }
        
    }
    
    func drawChart(rect: CGRect){
        let image = UIImage(named: "小圆点绿.png")
        guard let data = chartData else{
            return
        }
        let context = UIGraphicsGetCurrentContext()
        CGContextSetLineWidth(context, 2.0)
        CGContextBeginPath(context)
        let color = UIColor.mainGreenColor()
        CGContextSetStrokeColorWithColor(context, color.CGColor)
        let leftmargin : CGFloat = 50
        CGContextMoveToPoint(context, leftmargin ,rect.size.height - rect.size.height * (data[0].value! - minValue) / (maxValue - minValue))
        var imagePoint = [CGPoint]()
        for (index,item) in data.enumerate(){
            let formater = NSDateFormatter()
            formater.dateFormat = "MM.dd"
            let str = formater.stringFromDate(item.date)
            let attr = [NSFontAttributeName : UIFont.systemFontOfSize(10),
                NSForegroundColorAttributeName : UIColor.whiteColor()]
            let attStr = NSAttributedString(string: str, attributes: attr)
            let size = attStr.size()
            let strx : CGFloat
            if data.count == 1 {
                strx = leftmargin + size.width / 2
            }else {
                strx = leftmargin + (rect.size.width - leftmargin - 20) * CGFloat(index)/CGFloat(data.count - 1) - size.width / 2
            }
            let stry : CGFloat = rect.size.height - 10
            if index == 0 || index == data.count || shouldDrawAt(index){
                attStr.drawAtPoint(CGPoint(x: strx, y: stry))
            }
            CGContextSetStrokeColorWithColor(context, color.CGColor)
            guard let _ = item.value else{
                continue
            }
            let pos = strx + size.width / 2
            let height = rect.size.height - rect.size.height * (item.value! - minValue) / (maxValue - minValue)
            let imageX = pos - (image?.size.width)! / 2
            let imageY = height - (image?.size.height)! / 2
            CGContextAddLineToPoint(context, pos, height)
            imagePoint.append(CGPoint(x: imageX, y: imageY))
        }
        CGContextStrokePath(context)
        for point in imagePoint{
            image?.drawAtPoint(point)
        }
    }
    
    func shouldDrawAt(index : Int) -> Bool{
        guard let data = self.chartData else{
            return false
        }
        if data.count < 5 + 2 {
            return true
        }
        let step = (data.count - 2) / 5
        return (index - 1) % step == 0
    }
    
    override func drawRect(rect: CGRect) {
        // Drawing code
        super.drawRect(rect)
        if chartData == nil{
            return
        }
        chartData?.forEach({ (item) -> () in
            guard let value = item.value else{
                return
            }
            if value > maxValue{
                maxValue = value
            }
            if value < minValue{
                minValue = value
            }
        })
        minValue = CGFloat(Int(minValue) / 10 * 10)
        maxValue = CGFloat((Int(maxValue) / 10 + 1) * 10)
        drawCoordinate(rect)
        drawChart(rect)
    }

}
