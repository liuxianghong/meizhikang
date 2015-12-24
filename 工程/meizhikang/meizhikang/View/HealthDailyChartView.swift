//
//  HealthDailyChartView.swift
//  meizhikang
//
//  Created by shadowPriest on 15/12/24.
//  Copyright © 2015年 刘向宏. All rights reserved.
//

import UIKit

class HealthDailyChartView: UIView {

    var data: [DailyViewLineData]?
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
        super.drawRect(rect)
        print(rect)
        guard let data = self.data else{
            return
        }
        let context = UIGraphicsGetCurrentContext()
//        CGContextClearRect(context, rect)
//        CGContextSetStrokeColorWithColor(context, UIColor.whiteColor().CGColor)
//        CGContextFillRect(context, rect)
        CGContextSetLineWidth(context, 1.0)
        for item in data{
            let pos = CGFloat(item.position) * rect.size.width
            let color = UIColor.helathColorByValue(item.value)
            CGContextBeginPath(context)
            CGContextSetStrokeColorWithColor(context, color.CGColor)
            CGContextMoveToPoint(context, pos, 0)
            CGContextAddLineToPoint(context, pos, rect.size.height)
            CGContextStrokePath(context)
        }
    }

}
