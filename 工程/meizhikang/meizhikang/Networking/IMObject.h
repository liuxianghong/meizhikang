//
//  IMObject.h
//  meizhikang
//
//  Created by 刘向宏 on 15/12/11.
//  Copyright © 2015年 刘向宏. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NetWorkingContents.h"

typedef NSUInteger IMObjectSendingType;
NS_ENUM(IMMsgSendFromType) {
    IMObjectSendInit = 0,
    IMObjectSending  = 1,
    IMObjectSendFinished = 2,
};

@interface IMObject : NSObject
@property (nonatomic,strong) NSMutableData *data;
@property (nonatomic,strong) NSData *sendData;
@property (nonatomic,assign) IMObjectSendingType sendingType;
@property (nonatomic,assign) long tag;
@property (nonatomic,assign) long lenth;
@property (nonatomic,assign) UInt8 cmd;
@property (nonatomic,assign) UInt8 subCmd;
@property (nonatomic,copy) IMObjectReadHeadHandler readHead;
@property (nonatomic,copy) IMObjectCompletionHandler completion;
@property (nonatomic,copy) IMObjectFailureHandler failure;
-(instancetype)initWithTag:(long) tag;

@end
