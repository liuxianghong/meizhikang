//
//  UIColor+greenbaby.h
//  greenbaby
//
//  Created by 刘向宏 on 15/12/2.
//  Copyright © 2015年 刘向宏. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef NS_ENUM( NSInteger, HelathColorType)
{
    HelathColorTypeHealth,
    HelathColorTypeSubhealth,
    HelathColorTypeInfirm,
    HelathColorTypeUnhealthy,
};

@interface UIColor (gb)
+(UIColor *)mainGreenColor;

+(UIColor *)rgbColor:(UInt64)rgb;

+(UIColor *)helathColor:(HelathColorType)type;

+(UIColor *)helathColorByValue:(NSInteger)value;
@end
