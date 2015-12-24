//
//  IMRequst.h
//  meizhikang
//
//  Created by 刘向宏 on 15/12/21.
//  Copyright © 2015年 刘向宏. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IMConnect.h"

@interface IMRequst : NSObject

+(void)LoginWithUserName:(NSString *)userName PassWord:(NSString *)pw  completion:(IMObjectLoginHandler)completion failure:(IMObjectFailureHandler)failure;

+(void)registWithUserName:(NSString *)userName withCode:(NSString *)code withNickName:(NSString *)nickName withPW:(NSString *)pw withSex:(UInt8)sex withAge:(UInt8)age withHeiht:(UInt8)height withWight:(UInt16)wight completion:(void (^)())completion failure:(IMObjectFailureHandler)failure;

+(void)GetUserInfoCompletion:(void (^)(id info))completion failure:(IMObjectFailureHandler)failure;

+(void)SendMessage:(NSString *)text fromType:(IMMsgSendFromType)fromtype toid:(NSNumber *)toid completion:(void (^)(id info))completion failure:(IMObjectFailureHandler)failure;

+(void)GetMembersGroupByGid:(NSNumber *)gid completion:(void (^)(id info))completion failure:(IMObjectFailureHandler)failure;

+(void)CreateGroupByGid:(NSString *)groupName completion:(void (^)(id info))completion failure:(IMObjectFailureHandler)failure;

+(void)BGNotifyByDeviceToken:(NSString *)token completion:(void (^)(id info))completion failure:(IMObjectFailureHandler)failure;

+(void)LoginOut;
@end
