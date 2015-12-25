//
//  DottedLineView.m
//  meizhikang
//
//  Created by 刘向宏 on 15/12/25.
//  Copyright © 2015年 刘向宏. All rights reserved.
//

#import "DottedLineView.h"

@implementation DottedLineView

-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    
    // Drawing code
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    [shapeLayer setBounds:self.bounds];
    [shapeLayer setPosition:self.center];
    [shapeLayer setFillColor:[[UIColor clearColor] CGColor]];
    
    // 设置虚线颜色为blackColor
    [shapeLayer setStrokeColor:[[UIColor redColor] CGColor]];
    //[shapeLayer setStrokeColor:[[UIColor colorWithRed:223/255.0 green:223/255.0 blue:223/255.0 alpha:1.0f] CGColor]];
    
    // 3.0f设置虚线的宽度
    [shapeLayer setLineWidth:1.0f/2];
    [shapeLayer setLineJoin:kCALineJoinRound];
    
    // 3=线的宽度 1=每条线的间距
    [shapeLayer setLineDashPattern:
     [NSArray arrayWithObjects:[NSNumber numberWithInt:1],
      [NSNumber numberWithInt:1],nil]];
    
    // Setup the path
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path, NULL, 0.5, 0);
    CGPathAddLineToPoint(path, NULL, 0.5,500);
    
    //    // Setup the path
    //    CGMutablePathRef path = CGPathCreateMutable();
    //    // 0,10代表初始坐标的x，y
    //    // 320,10代表初始坐标的x，y
    //    CGPathMoveToPoint(path, NULL, 0, 10);
    //    CGPathAddLineToPoint(path, NULL, 320,10);
    
    [shapeLayer setPath:path];
    CGPathRelease(path);
    
    // 可以把self改成任何你想要的UIView, 下图演示就是放到UITableViewCell中的
    [[self layer] addSublayer:shapeLayer];
    
    return self;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
//- (void)drawRect:(CGRect)rect {
//    
//}


@end
