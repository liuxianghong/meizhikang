//
//  IMConnect.h
//  meizhikang
//
//  Created by 刘向宏 on 15/12/9.
//  Copyright © 2015年 刘向宏. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IMObject.h"

@protocol IMConnectDelegate <NSObject>

@end

@interface IMConnect : NSObject
+(instancetype)Instance;
-(void)getToken:(NSString *)userName completion:(IMObjectTokenCompletionHandler)completion failure:(IMObjectFailureHandler)failure;

-(void)login:(NSString *)pw withToken:(NSData *)token completion:(IMObjectLoginHandler)completion failure:(IMObjectFailureHandler)failure;

-(void)test;
- (void)portTest;
@end
