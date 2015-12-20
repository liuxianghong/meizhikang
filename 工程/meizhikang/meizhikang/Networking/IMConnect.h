//
//  IMConnect.h
//  meizhikang
//
//  Created by 刘向宏 on 15/12/9.
//  Copyright © 2015年 刘向宏. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IMObject.h"

typedef void (^IMObjectTokenCompletionHandler)(NSData *token,NSData *data);
typedef void (^IMObjectLoginHandler)(UInt32 ip,UInt16 port);

@protocol IMConnectDelegate <NSObject>

@end

@interface IMConnect : NSObject
+(instancetype)Instance;
-(void)getToken:(NSString *)userName completion:(IMObjectTokenCompletionHandler)completion failure:(IMObjectFailureHandler)failure;

-(void)login:(NSString *)pw withToken:(NSData *)token completion:(IMObjectLoginHandler)completion failure:(IMObjectFailureHandler)failure;

-(void)getRegistToken:(NSString *)userName completion:(IMObjectTokenCompletionHandler)completion failure:(IMObjectFailureHandler)failure;

-(void)registWithToken:(NSData *)token withCode:(NSString *)code withNickName:(NSString *)nickName withPW:(NSString *)pw withSex:(UInt8)sex withAge:(UInt8)age withHeiht:(UInt8)height withWight:(UInt16)wight completion:(void (^)())completion failure:(IMObjectFailureHandler)failure;

-(void)getResetPWToken:(NSString *)userName completion:(IMObjectTokenCompletionHandler)completion failure:(IMObjectFailureHandler)failure;

-(void)getCode:(NSString *)phoenName code:(NSString *)code completion:(IMObjectTokenCompletionHandler)completion failure:(IMObjectFailureHandler)failure;

-(void)RequstUserInfo:(NSDictionary *)dic completion:(void (^)(id info))completion failure:(IMObjectFailureHandler)failure;

//发送图片。语音
-(void)UploadFileRequst:(NSData *)file fileType:(IMMsgSendFileType)fieType fromType:(IMMsgSendFromType)fromtype toid:(NSNumber *)toid completion:(void (^)(id info))completion failure:(IMObjectFailureHandler)failure;

-(void)test:(NSData *)token;
@end
