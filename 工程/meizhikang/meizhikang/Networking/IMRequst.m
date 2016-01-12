//
//  IMRequst.m
//  meizhikang
//
//  Created by 刘向宏 on 15/12/21.
//  Copyright © 2015年 刘向宏. All rights reserved.
//

#import "IMRequst.h"
#import "IMConnect.h"

@implementation IMRequst

+(void)LoginWithUserName:(NSString *)userName PassWord:(NSString *)pw  completion:(IMObjectLoginHandler)completion failure:(IMObjectFailureHandler)failure{
    [IMRequst LoginOut:true];
    [[IMConnect Instance] getToken:userName completion:^(NSData *token, NSData *data) {
        [[IMConnect Instance] login:pw withToken:token completion:completion failure:failure];
    } failure:failure];
}


+(void)registWithUserName:(NSString *)userName withCode:(NSString *)code withNickName:(NSString *)nickName withPW:(NSString *)pw withSex:(UInt8)sex withAge:(UInt8)age withHeiht:(UInt8)height withWight:(UInt16)wight completion:(void (^)())completion failure:(IMObjectFailureHandler)failure{
    [[IMConnect Instance] getRegistToken:userName completion:^(NSData *token, NSData *data) {
        [[IMConnect Instance] registWithToken:token withCode:code withNickName:nickName withPW:pw withSex:sex withAge:age withHeiht:height withWight:wight completion:completion failure:failure];
    } failure:failure];
}

+(void)GetUserInfoCompletion:(void (^)(id info))completion failure:(IMObjectFailureHandler)failure{
    NSDictionary *dic = @{
                          @"type" : @"account"
                          };
    [[IMConnect Instance] RequstUserInfo:dic completion:completion failure:failure];
}

+(void)SendMessage:(NSString *)text fromType:(IMMsgSendFromType)fromtype toid:(NSNumber *)toid completion:(void (^)(id info))completion failure:(IMObjectFailureHandler)failure{
    NSString *content = [NSString stringWithFormat:@"[text]%@[/text]",text];
    UInt32 uuid = [NSDate date].timeIntervalSince1970;
    NSDictionary *dic = @{
                          @"type" : @"send_msg",
                          @"uuid" : @(uuid),
                          @"fromtype" : @(fromtype),
                          @"toid" : toid,
                          @"content" : content
                          };
    [[IMConnect Instance] RequstUserInfo:dic completion:completion failure:failure];
}

+(void)GetMembersGroupByGid:(NSNumber *)gid completion:(void (^)(id info))completion failure:(IMObjectFailureHandler)failure{
    NSDictionary *dic = @{
                          @"type" : @"members",
                          @"gid" : gid
                          };
    [[IMConnect Instance] RequstUserInfo:dic completion:completion failure:failure];
}

+(void)CreateGroupByGid:(NSString *)groupName completion:(void (^)(id info))completion failure:(IMObjectFailureHandler)failure{
    NSDictionary *dic = @{
                          @"type" : @"group_add",
                          @"gname" : groupName
                          };
    [[IMConnect Instance] RequstUserInfo:dic completion:completion failure:failure];
}

+(void)DeleteGroupByGid:(NSNumber *)gid completion:(void (^)(id info))completion failure:(IMObjectFailureHandler)failure{
    NSDictionary *dic = @{
                          @"type" : @"del_group",
                          @"gid": gid
                          };
    [[IMConnect Instance] RequstUserInfo:dic completion:completion failure:failure];
}

+(void)QuitGroupByGid:(NSNumber *)gid completion:(void (^)(id info))completion failure:(IMObjectFailureHandler)failure{
    NSDictionary *dic = @{
                          @"type" : @"quit_group",
                          @"gid": gid
                          };
    [[IMConnect Instance] RequstUserInfo:dic completion:completion failure:failure];
}

+(void)UpdateGroupNameByGid:(NSNumber *)gid name:(NSString *)groupName completion:(void (^)(id info))completion failure:(IMObjectFailureHandler)failure{
    NSDictionary *dic = @{
                          @"type" : @"modify_group",
                          @"gname" : groupName,
                          @"gid": gid
                          };
    [[IMConnect Instance] RequstUserInfo:dic completion:completion failure:failure];
}

+(void)BGNotifyByDeviceToken:(NSString *)token completion:(void (^)(id info))completion failure:(IMObjectFailureHandler)failure{
    
    if (![[IMConnect Instance]isLogin]) {
        failure(nil);
        return;
    }
    NSDictionary *dic = @{
                          @"type" : @"ios_bg_notify",
                          @"device" : token
                          };
    [[IMConnect Instance] RequstUserInfo:dic completion:completion failure:failure];
}

+(void)getRegistToken:(NSString *)userName completion:(IMObjectTokenCompletionHandler)completion failure:(IMObjectFailureHandler)failure{
    [[IMConnect Instance] getRegistToken:userName completion:completion failure:failure];
}


+(void)registWithToken:(NSData *)token withCode:(NSString *)code withNickName:(NSString *)nickName withPW:(NSString *)pw withSex:(UInt8)sex withAge:(UInt8)age withHeiht:(UInt8)height withWight:(UInt16)wight completion:(void (^)())completion failure:(IMObjectFailureHandler)failure{
    [[IMConnect Instance] registWithToken:token withCode:code withNickName:nickName withPW:pw withSex:sex withAge:age withHeiht:height withWight:wight completion:completion failure:failure];
}

+(void)getResetPWToken:(NSString *)userName completion:(IMObjectTokenCompletionHandler)completion failure:(IMObjectFailureHandler)failure{
    [[IMConnect Instance] getResetPWToken:userName completion:completion failure:failure];
}

+(void)getCode:(NSString *)phoenName code:(NSString *)code completion:(IMObjectTokenCompletionHandler)completion failure:(IMObjectFailureHandler)failure{
    [[IMConnect Instance] getCode:phoenName code:code completion:completion failure:failure];
}

+(void)RequstUserInfo:(NSDictionary *)dic completion:(void (^)(id info))completion failure:(IMObjectFailureHandler)failure{
    [[IMConnect Instance] RequstUserInfo:dic completion:completion failure:failure];
}

//发送图片。语音
+(void)UploadFileRequst:(NSData *)file fileType:(IMMsgSendFileType)fieType fromType:(IMMsgSendFromType)fromtype toid:(NSNumber *)toid completion:(void (^)(id info))completion failure:(IMObjectFailureHandler)failure{
    [[IMConnect Instance] UploadFileRequst:file fileType:fieType fromType:fromtype toid:toid completion:completion failure:failure];
}

+(void)LoginOut:(BOOL)waite{
    [[IMConnect Instance] LoginOut:waite];
}
@end
