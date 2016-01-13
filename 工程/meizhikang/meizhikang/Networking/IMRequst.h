//
//  IMRequst.h
//  meizhikang
//
//  Created by 刘向宏 on 15/12/21.
//  Copyright © 2015年 刘向宏. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NetWorkingContents.h"


@interface IMRequst : NSObject

+(void)LoginWithUserName:(NSString *)userName PassWord:(NSString *)pw  completion:(IMObjectLoginHandler)completion failure:(IMObjectFailureHandler)failure;

+(void)registWithUserName:(NSString *)userName withCode:(NSString *)code withNickName:(NSString *)nickName withPW:(NSString *)pw withSex:(UInt8)sex withAge:(UInt8)age withHeiht:(UInt8)height withWight:(UInt16)wight completion:(void (^)())completion failure:(IMObjectFailureHandler)failure;

+(void)GetUserInfoCompletion:(void (^)(id info))completion failure:(IMObjectFailureHandler)failure;

+(void)SendMessage:(NSString *)text fromType:(IMMsgSendFromType)fromtype toid:(NSNumber *)toid completion:(void (^)(id info))completion failure:(IMObjectFailureHandler)failure;

+(void)GetMembersGroupByGid:(NSNumber *)gid completion:(void (^)(id info))completion failure:(IMObjectFailureHandler)failure;

+(void)CreateGroupByGid:(NSString *)groupName completion:(void (^)(id info))completion failure:(IMObjectFailureHandler)failure;

+(void)DeleteGroupByGid:(NSNumber *)gid completion:(void (^)(id info))completion failure:(IMObjectFailureHandler)failure;

+(void)QuitGroupByGid:(NSNumber *)gid completion:(void (^)(id info))completion failure:(IMObjectFailureHandler)failure;

+(void)UpdateGroupNameByGid:(NSNumber *)gid name:(NSString *)groupName completion:(void (^)(id info))completion failure:(IMObjectFailureHandler)failure;

+(void)BGNotifyByDeviceToken:(NSString *)token completion:(void (^)(id info))completion failure:(IMObjectFailureHandler)failure;

+(void)getRegistToken:(NSString *)userName completion:(IMObjectTokenCompletionHandler)completion failure:(IMObjectFailureHandler)failure;

+(void)registWithToken:(NSData *)token withCode:(NSString *)code withNickName:(NSString *)nickName withPW:(NSString *)pw withSex:(UInt8)sex withAge:(UInt8)age withHeiht:(UInt8)height withWight:(UInt16)wight completion:(void (^)())completion failure:(IMObjectFailureHandler)failure;

+(void)getResetPWToken:(NSString *)userName completion:(IMObjectTokenCompletionHandler)completion failure:(IMObjectFailureHandler)failure;

+(void)getCode:(NSString *)phoenName code:(NSString *)code completion:(IMObjectTokenCompletionHandler)completion failure:(IMObjectFailureHandler)failure;

+(void)RequstUserInfo:(NSDictionary *)dic completion:(void (^)(id info))completion failure:(IMObjectFailureHandler)failure;

//发送图片。语音
+(void)UploadFileRequst:(NSData *)file fileType:(IMMsgSendFileType)fieType fromType:(IMMsgSendFromType)fromtype toid:(NSNumber *)toid completion:(void (^)(id info))completion failure:(IMObjectFailureHandler)failure;

+(void)LoginOut:(BOOL)waite;

+(void)EmailApplyByGid:(NSNumber *)gid uid:(NSNumber *)uid tye:(NSNumber *)type completion:(void (^)(id info))completion failure:(IMObjectFailureHandler)failure;

+(void)EmailInviteByGid:(NSNumber *)gid tye:(NSNumber *)type completion:(void (^)(id info))completion failure:(IMObjectFailureHandler)failure;

+(void)ApplyGroupByGid:(NSNumber *)gid completion:(void (^)(id info))completion failure:(IMObjectFailureHandler)failure;


+(void)EmailReadByGid:(NSNumber *)gid uuid:(NSNumber *)uuid;

+(void)AddMemberByGid:(NSNumber *)gid uid:(NSNumber *)uid completion:(void (^)(id info))completion failure:(IMObjectFailureHandler)failure;
@end
