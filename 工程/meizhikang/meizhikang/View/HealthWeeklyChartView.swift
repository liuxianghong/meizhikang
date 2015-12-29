//
//  HealthWeeklyChartView.swift
//  meizhikang
//
//  Created by shadowPriest on 15/12/28.
//  Copyright © 2015年 刘向宏. All rights reserved.
//

import UIKit

class HealthWeeklyChartView: UIView {

    var chartData: [WeeklyViewLineData]?
    var minValue: CGFloat = 100
    var maxValue: CGFloat = 0
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
        super.drawRect(rect)
        let image = UIImage(named: "小圆点绿.png")
        chartData?.forEach({ (item) -> () in
            if item.value > maxValue{
                maxValue = item.value
            }
            if item.value < minValue{
                minValue = item.value
            }
        })
        minValue = CGFloat(Int(minValue) / 10 * 10)
        maxValue = CGFloat((Int(maxValue) / 10 + 1) * 10)
        guard let data = chartData else{
            return
        }
        let context = UIGraphicsGetCurrentContext()
        CGContextSetLineWidth(context, 2.0)
        CGContextBeginPath(context)
        let color = UIColor.mainGreenColor()
        CGContextSetStrokeColorWithColor(context, color.CGColor)
        CGContextMoveToPoint(context, 0,rect.size.height - rect.size.height * (data[0].value - minValue) / (maxValue - minValue))
        var imagePoint = [CGPoint]()
        for (index,item) in data.enumerate(){
            let pos = rect.size.width * CGFloat(index)/CGFloat(data.count - 1)//CGFloat(item.position) * rect.size.width
            let height = rect.size.height - rect.size.height * (item.value - minValue) / (maxValue - minValue)
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

}
