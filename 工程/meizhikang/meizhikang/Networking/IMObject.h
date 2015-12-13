//
//  IMObject.h
//  meizhikang
//
//  Created by 刘向宏 on 15/12/11.
//  Copyright © 2015年 刘向宏. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NetWorkingContents.h"


typedef void (^IMObjectCompletionHandler)(NSData *data);
typedef long (^IMObjectReadHeadHandler)(long lenth);
typedef void (^IMObjectFailureHandler)(NSError *error);


@interface IMObject : NSObject
@property (nonatomic,strong) NSMutableData *data;
@property (nonatomic,assign) BOOL finished;
@property (nonatomic,assign) long tag;
@property (nonatomic,assign) long lenth;
@property (nonatomic,copy) IMObjectReadHeadHandler readHead;
@property (nonatomic,copy) IMObjectCompletionHandler completion;
@property (nonatomic,copy) IMObjectFailureHandler failure;
-(instancetype)initWithTag:(long) tag;

@end
