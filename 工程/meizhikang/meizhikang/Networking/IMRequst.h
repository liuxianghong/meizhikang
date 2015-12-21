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

+(void)SendMessage:(NSString *)text fromType:(IMMsgSendFromType)fromtype toid:(NSNumber *)toid completion:(void (^)(id info))completion failure:(IMObjectFailureHandler)failure;

+(void)GetMembersGroupByGid:(NSNumber *)gid completion:(void (^)(id info))completion failure:(IMObjectFailureHandler)failure;

+(void)CreateGroupByGid:(NSString *)groupName completion:(void (^)(id info))completion failure:(IMObjectFailureHandler)failure;
@end
