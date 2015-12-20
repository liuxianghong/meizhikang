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
