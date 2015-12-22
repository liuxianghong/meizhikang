//
//  NetWorkingContents.h
//  meizhikang
//
//  Created by 刘向宏 on 15/12/12.
//  Copyright © 2015年 刘向宏. All rights reserved.
//

#import <Foundation/Foundation.h>


#define IMTIMEOUT 10
#define IM_MAGIC 0xbebaedfe

typedef void (^IMObjectCompletionHandler)(NSData *data);
typedef UInt32 (^IMObjectReadHeadHandler)(UInt32 lenth);
typedef void (^IMObjectFailureHandler)(NSError *error);
typedef void (^IMObjectTokenCompletionHandler)(NSData *token,NSData *data);
typedef void (^IMObjectLoginHandler)(UInt32 ip,UInt16 port);

typedef NSUInteger IMMsgSendFromType;
NS_ENUM(IMMsgSendFromType) {
    IMMsgSendFromTypePepole = 0,
    IMMsgSendFromTypeGroup  = 1,
    
};

typedef UInt8 IMMsgSendFileType;
NS_ENUM(IMMsgSendFileType) {
    IMMsgSendFileTypeVoice  = 1,
    IMMsgSendFileTypeImage  = 2,
};


@interface NetWorkingContents : NSObject
+(NSString *)getReturnDescription:(NSInteger)code;
@end
