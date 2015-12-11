//
//  IMObject.h
//  meizhikang
//
//  Created by 刘向宏 on 15/12/11.
//  Copyright © 2015年 刘向宏. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^IMObjectTokenCompletionHandler)(NSData *token,int time);
typedef void (^IMObjectCompletionHandler)(NSData *data);
typedef void (^IMObjectFailureHandler)(NSError *error);
typedef void (^IMObjectLoginHandler)(UInt32 ip,UInt16 port);

@interface IMObject : NSObject
@property (nonatomic,strong) NSMutableData *data;
@property (nonatomic,assign) BOOL finished;
@property (nonatomic,assign) long tag;
@property (nonatomic,assign) long lenth;
@property (nonatomic,copy) IMObjectCompletionHandler completion;
@property (nonatomic,copy) IMObjectFailureHandler failure;
-(instancetype)initWithTag:(long) tag;

@end
