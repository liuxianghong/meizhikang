//
//  NSString+scisky.h
//  scisky
//
//  Created by 刘向宏 on 15/6/18.
//  Copyright © 2015年 刘向宏. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

void oxr(Byte *d,const Byte *s);
void oxrMD5(Byte *d,const Byte *s);
void oxrPWToken(Byte *d,const Byte *p,const Byte *t);

@interface NSString (scisky)
+(NSData *)AESAndXOREncrypt:(NSData *)token data:(NSData *)data;
+(NSData *)AESAndXORDecrypt:(NSData *)token data:(NSData *)data;
-(NSData *) dataFromMD5;
-(NSData *)AESEncrypt;
+(NSData *)AESDecrypt:(NSData *)data;
+(NSData *)encryptWithAESkey:(Byte *)key type:(NSInteger)type data:(NSData *)data;
+ (NSData *)decryptWithAES:(NSData *)data withKey:(const void *)key;
- (BOOL)checkTel;
+ (BOOL)validateIDCardNumber:(NSString *)value;
- (BOOL)isValidateEmail;
@end

@interface UIFont (wb)
+(UIFont *)appFontOfSize:(CGFloat)size;
@end