//
//  IMObject.m
//  meizhikang
//
//  Created by 刘向宏 on 15/12/11.
//  Copyright © 2015年 刘向宏. All rights reserved.
//

#import "IMObject.h"

@implementation IMObject
{
    NSTimer *countDownTimer;
}

-(instancetype)initWithTag:(long) tag{
    self = [super init];
    self.data = [[NSMutableData alloc]init];
    self.tag = tag;
    self.sendingType = IMObjectSendInit;
    countDownTimer = [NSTimer scheduledTimerWithTimeInterval:IMTIMEOUT target:self selector:@selector(countDown) userInfo:nil repeats:NO];
    return self;
}

-(void)setSendingType:(IMObjectSendingType)sendingType
{
    _sendingType = sendingType;
    if (sendingType != IMObjectSendInit) {
        if (countDownTimer) {
            [countDownTimer invalidate];
            countDownTimer = nil;
        }
    }
    if (sendingType == IMObjectSending){
        countDownTimer = [NSTimer scheduledTimerWithTimeInterval:(IMTIMEOUT+10) target:self selector:@selector(countDown) userInfo:nil repeats:NO];
    }
}

-(void)countDown{
    if (countDownTimer) {
        [countDownTimer invalidate];
        countDownTimer = nil;
    }
    _sendingType = IMObjectSendFinished;
    if (self.failure) {
        self.failure([NSError errorWithDomain:@"超时" code:0 userInfo:nil]);
    }
    
}

-(void)dealloc{
    //NSLog(@"IMObject dealloc");
}
@end
