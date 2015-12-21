//
//  IMRequst.m
//  meizhikang
//
//  Created by 刘向宏 on 15/12/21.
//  Copyright © 2015年 刘向宏. All rights reserved.
//

#import "IMRequst.h"

@implementation IMRequst

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
@end
