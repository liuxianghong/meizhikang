//
//  IMObject.m
//  meizhikang
//
//  Created by 刘向宏 on 15/12/11.
//  Copyright © 2015年 刘向宏. All rights reserved.
//

#import "IMObject.h"

@implementation IMObject 
-(instancetype)initWithTag:(long) tag{
    self = [super init];
    self.data = [[NSMutableData alloc]init];
    self.tag = tag;
    self.finished = NO;
    return self;
}
@end
