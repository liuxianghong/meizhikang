//
//  MZKSearchRequst.h
//  meizhikang
//
//  Created by 刘向宏 on 16/1/13.
//  Copyright © 2016年 刘向宏. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MZKSearchRequst : NSObject

+(void)SearchGroupWithParameters:(NSString *)parameters success:(void (^)(id responseObject))success failure:(void (^)(NSError *error))failure;

+(void)SearchMemberWithParameters:(NSString *)parameters success:(void (^)(id responseObject))success failure:(void (^)(NSError *error))failure;
@end
