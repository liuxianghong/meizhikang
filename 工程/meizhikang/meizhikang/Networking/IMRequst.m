//
//  IMRequst.m
//  meizhikang
//
//  Created by 刘向宏 on 15/12/21.
//  Copyright © 2015年 刘向宏. All rights reserved.
//

#import "IMRequst.h"

@implementation IMRequst

+(void)LoginWithUserName:(NSString *)userName PassWord:(NSString *)pw  completion:(IMObjectLoginHandler)completion failure:(IMObjectFailureHandler)failure{
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

+(void)LoginOut{
    [[IMConnect Instance] LoginOut];
}
@end
