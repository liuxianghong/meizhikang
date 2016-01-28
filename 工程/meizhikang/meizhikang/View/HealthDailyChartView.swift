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
    var scale: CGFloat = 1.0
    override var transform: CGAffineTransform{
        set{
            var constrainedTransform = newValue
            constrainedTransform.d = 1.0
            let scale = constrainedTransform.a
            constrainedTransform = CGAffineTransformTranslate(constrainedTransform, 0.0, (scale - 1) * -36)
            super.transform = constrainedTransform
        }
        get{
            return super.transform
        }
    }
//    override var frame: CGRect{
//        set{
//            var nFrame = newValue
//            nFrame.origin.x = 0
//            nFrame.origin.y = 0
//            super.frame = nFrame
//        }
//        get{
//            return super.frame
//        }
//    }
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
        CGContextSetLineWidth(context, self.scale)
        for item in data{
            let pos = CGFloat(item.position) * rect.size.width + self.scale * 0.5
            let color = UIColor.helathColorByValue(item.value)
            CGContextBeginPath(context)
            CGContextSetStrokeColorWithColor(context, color.CGColor)
            CGContextMoveToPoint(context, pos, rect.size.height)
            CGContextAddLineToPoint(context, pos, rect.size.height - rect.size.height * CGFloat(item.value) / 100)
            CGContextStrokePath(context)
        }
    }
    
}
