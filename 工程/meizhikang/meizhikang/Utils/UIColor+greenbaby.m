//
//  UIColor+greenbaby.m
//  greenbaby
//
//  Created by 刘向宏 on 15/12/2.
//  Copyright © 2015年 刘向宏. All rights reserved.
//

#import "UIColor+greenbaby.h"

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

@implementation UIColor (gb)
+(UIColor *)mainGreenColor
{
    return [self rgbColor:0x009900];
}

+(UIColor *)rgbColor:(UInt64)rgb
{
    return UIColorFromRGB(rgb);
}

+(UIColor *)helathColor:(HelathColorType)type{
    switch (type) {
        case HelathColorTypeHealth:
        {
            return UIColorFromRGB(0x00ff00);
        }
        break;
        case HelathColorTypeSubhealth:
        {
            return UIColorFromRGB(0x23debf);
        }
        break;
        case HelathColorTypeInfirm:
        {
            return UIColorFromRGB(0xb5b5b6);
        }
        break;
        case HelathColorTypeUnhealthy:
        {
            return UIColorFromRGB(0x727171);
        }
        break;
        
        default:
        {
            return UIColorFromRGB(0xffffff);
        }
        break;
    }
}

+(UIColor *)helathColorByValue:(NSInteger)value{
    if (value>=80) {
        return [self helathColor:HelathColorTypeHealth];
    }
    else if (value>=70) {
        return [self helathColor:HelathColorTypeSubhealth];
    }
    else if (value>=60) {
        return [self helathColor:HelathColorTypeInfirm];
    }
    else{
        return [self helathColor:HelathColorTypeUnhealthy];
    }
    
}

@end
