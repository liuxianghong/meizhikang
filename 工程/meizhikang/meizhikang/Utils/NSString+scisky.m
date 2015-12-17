//
//  NSString+scisky.m
//  scisky
//
//  Created by 刘向宏 on 15/6/18.
//  Copyright © 2015年 刘向宏. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CommonCrypto/CommonCryptor.h>
#import <CommonCrypto/CommonKeyDerivation.h>
#import "NSString+scisky.h"
#define KeyStr @"@1111111111111111"

Byte aesKey[] = {0x37, 0x68, 0x99, 0x76, 0x13, 0x1b, 0x3c, 0xdd,0x19, 0x88, 0x7d, 0x1f,0xf3, 0xad, 0xde, 0x01,0x00};
//Byte dd[] = {0xa9, 0x5d, 0xc7, 0x1a, 0x4f, 0xdd, 0xd3, 0x18, 0x42, 0x4f, 0x99, 0xb3, 0x8c, 0x2b, 0xe1, 0x1f, 0xe9, 0xa3, 0x32, 0x4f, 0xe7, 0x66, 0x0a, 0x8b, 0x78, 0xc6, 0x75, 0x48, 0x35, 0x19, 0x9d, 0xfe};

void oxr(Byte *d,const Byte *s){
    oxrPWToken(d,s,aesKey);
}

void oxrMD5(Byte *d,const Byte *s){
    for (int i = 0; i<16; i++) {
        Byte n = s[i];
        Byte m = aesKey[i];
        d[i] = n^m;
    }
}

void oxrPWToken(Byte *d,const Byte *t,const Byte *p){
    for (int i = 0; i<16; i++) {
        int j = i % 4;
        Byte n = t[j];
        Byte m = p[i];
        d[i] = n^m;
    }
}

@implementation NSString (scisky)

+ (NSString *)decodeFromPercentEscapeString: (NSString *) input
{
    NSMutableString *outputStr = [NSMutableString stringWithString:input];
    [outputStr replaceOccurrencesOfString:@"+"
                               withString:@" "
                                  options:NSLiteralSearch
                                    range:NSMakeRange(0, [outputStr length])];
    
    return [outputStr stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
}

+ (NSString *)encodeToPercentEscapeString:(NSString *)input{
    NSString *outputStr = (NSString *)
    CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                              (CFStringRef)input,
                                                              NULL,
                                                              NULL,
                                                              kCFStringEncodingUTF8));
    return [outputStr lowercasePercent];
}

- (NSString *)lowercasePercent{
    NSData *data = [self dataUsingEncoding:NSUTF8StringEncoding];
    Byte *myByte = (Byte *)[data bytes];
    int i=0;
    int length = (int)[data length];
    while (i<[data length]){
        if (myByte[i] == '%')
        {
            i++;
            if ((myByte [i]>='A')&&(myByte [i]<='Z'))
                myByte[i]=myByte[i]-'A'+'a';
            i++;
            if ((myByte [i]>='A')&&(myByte [i]<='Z'))
                myByte[i]=myByte[i]-'A'+'a';
        }
        i++;
    }
    data = [NSData dataWithBytes:myByte length:length];
    NSString *ret = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    return ret;
}

+(NSData *)AESAndXOREncrypt:(NSData *)token data:(NSData *)data{
    Byte key[16];
    oxr(key, [token bytes]+4);
    return [NSString encryptWithAESkey:key type:1 data:data];
}

+(NSData *)AESAndXORDecrypt:(NSData *)token data:(NSData *)data{
    Byte key[16];
    oxr(key, [token bytes]+4);
    return [NSString decryptWithAES:data withKey:key];
}

-(NSData *)AESEncrypt{
    return [NSString encryptWithAESkey:aesKey type:0 data:[self dataUsingEncoding:NSUTF8StringEncoding]];
}

+(NSData *)AESDecrypt:(NSData *)data{
    return [self decryptWithAES:data withKey:aesKey];
}

+ (NSData *)encryptWithAESkey:(Byte *)key type:(NSInteger)type data:(NSData *)data{
    
    NSUInteger dataLength = [data length];
    if (type == 0) {
        NSUInteger hexLength = 16 - dataLength%16;
        dataLength = dataLength + hexLength;
    }
    
    char *context = malloc(dataLength);
    bzero(context, dataLength);
    memcpy(context, [data bytes], [data length]);
    
    size_t bufferSize = dataLength + kCCBlockSizeAES128;
    void *buffer = malloc(bufferSize);
    
    size_t numBytesCrypted = 0;
    CCCryptorStatus cryptStatus = CCCrypt(kCCEncrypt,
                                          kCCAlgorithmAES128,
                                          kCCOptionPKCS7Padding,
                                          key,
                                          kCCBlockSizeAES128,
                                          nil,
                                          context,//[data bytes],
                                          dataLength,
                                          buffer,
                                          bufferSize,
                                          &numBytesCrypted);
    if (cryptStatus == kCCSuccess) {
        //return [NSData dataWithBytes:dd length:32];
        return [NSData dataWithBytesNoCopy:buffer length:numBytesCrypted];
    }
    free(buffer);
    return nil;
    
}

+ (NSData *)decryptWithAES:(NSData *)data withKey:(const void *)key//解密
{
    char keyPtr[kCCKeySizeAES128+1];
    bzero(keyPtr, sizeof(keyPtr));
    memcpy(keyPtr, key, 16);
    NSUInteger dataLength = [data length];
    size_t bufferSize = dataLength + kCCBlockSizeAES128;
    void *buffer = malloc(bufferSize);
    size_t numBytesDecrypted = 0;
    CCCryptorStatus cryptStatus = CCCrypt(kCCDecrypt, kCCAlgorithmAES128,
                                          kCCOptionPKCS7Padding ,
                                          keyPtr, kCCBlockSizeAES128,
                                          nil,
                                          [data bytes], dataLength,
                                          buffer, bufferSize,
                                          &numBytesDecrypted);
    if (cryptStatus == kCCSuccess) {
        return [NSData dataWithBytesNoCopy:buffer length:numBytesDecrypted];
        
    }
    free(buffer);
    return nil;
}

- (NSData *) dataFromMD5{
    
    if(self == nil || [self length] == 0)
        return nil;
    
    const char *value = [self UTF8String];
    
    unsigned char outputBuffer[CC_MD5_DIGEST_LENGTH];
    CC_MD5(value, (CC_LONG)strlen(value), outputBuffer);
    
    return [NSData dataWithBytes:outputBuffer length:CC_MD5_DIGEST_LENGTH];
//    NSMutableString *outputString = [[NSMutableString alloc] initWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
//    for(NSInteger count = 0; count < CC_MD5_DIGEST_LENGTH; count++){
//        [outputString appendFormat:@"%02x",outputBuffer[count]];
//    }
//    
//    return outputString;
}

- (NSString *)formatData{
    NSMutableString *str=[self mutableCopy];
    NSString *rangeStr1 = @"<";
    NSString *rangeStr2 = @">";
    NSString *rangeStr3 = @" ";
    NSRange range = [str rangeOfString:rangeStr1];
    [str deleteCharactersInRange:range];
    range = [str rangeOfString:rangeStr2];
    [str deleteCharactersInRange:range];
    range = [str rangeOfString:rangeStr3];
    while (range.location != NSNotFound){
        [str deleteCharactersInRange:range];
        range = [str rangeOfString:rangeStr3];
    }
    return [str uppercaseString];
}

- (NSString *)decryptWithDES{
    NSData *data = [self dataUsingEncoding:NSUTF8StringEncoding];
    char *vplainText = strdup([self UTF8String]);//calloc([self length] * sizeof(char) + 1);
    //    strcpy(vplainText, [self UTF8String]);
    char *plain = malloc([self length] / 2 *sizeof(char));
    for (int i=0;i<[self length] / 2;i++)
    {
        int a=0;
        if (vplainText[i * 2]>='A' && vplainText[i * 2]<='Z')
            a = vplainText[i * 2] - 'A' + 10;
        if (vplainText[i * 2]>='0' && vplainText[i * 2]<='9')
            a = vplainText[i * 2] - '0';
        int b=0;
        if (vplainText[i * 2 + 1]>='A' && vplainText[i * 2 + 1]<='Z')
            b = vplainText[i * 2 + 1] - 'A' + 10;
        if (vplainText[i * 2 + 1]>='0' && vplainText[i * 2 + 1]<='9')
            b = vplainText[i * 2 + 1] - '0';
        plain[i] = a * 16 + b;
    }
    free(vplainText);
    CCCryptorStatus ccStatus;
    const void *vinitVec = (const void *) [KeyStr UTF8String];
    size_t plainTextBufferSize = [data length];
    size_t bufferPtrSize = 0;
    uint8_t *bufferPtr = NULL;
    size_t movedBytes = 0;
    bufferPtrSize = (plainTextBufferSize + kCCBlockSize3DES) & ~(kCCBlockSize3DES - 1);
    bufferPtr = malloc( bufferPtrSize * sizeof(uint8_t));
    memset((void *)bufferPtr, 0x0, bufferPtrSize);
    
    ccStatus = CCCrypt(kCCDecrypt,
                       kCCAlgorithmDES,
                       kCCOptionPKCS7Padding,
                       [KeyStr UTF8String],
                       kCCKeySizeDES,
                       vinitVec,
                       plain,
                       [self length] / 2,
                       (void *)bufferPtr,
                       bufferPtrSize,
                       &movedBytes);
    free(plain);
    NSData *myData = [NSData dataWithBytes:(const void *)bufferPtr length:(NSUInteger)movedBytes];
    free(bufferPtr);
    NSString *ret = [[NSString alloc] initWithData:myData encoding:NSUTF8StringEncoding];
    return ret;
}

- (BOOL)checkTel
{
    if ([self length] == 0) {
        return NO;
    }
    
    /**
     * 手机号码
     * 移动：134[0-8],135,136,137,138,139,150,151,157,158,159,182,187,188
     * 联通：130,131,132,152,155,156,185,186
     * 电信：133,1349,153,180,189
     */
    NSString * MOBILE = @"^1(3[0-9]|5[0-35-9]|8[025-9])\\d{8}$";
    /**
     10         * 中国移动：China Mobile
     11         * 134[0-8],135,136,137,138,139,150,151,157,158,159,182,187,188
     12         */
    NSString * CM = @"^1(34[0-8]|(3[5-9]|5[017-9]|8[278])\\d)\\d{7}$";
    /**
     15         * 中国联通：China Unicom
     16         * 130,131,132,152,155,156,185,186
     17         */
    NSString * CU = @"^1(3[0-2]|5[256]|8[56])\\d{8}$";
    /**
     20         * 中国电信：China Telecom
     21         * 133,1349,153,180,189
     22         */
    NSString * CT = @"^1((33|53|8[019])[0-9]|349)\\d{7}$";
    /**
     25         * 大陆地区固话及小灵通
     26         * 区号：010,020,021,022,023,024,025,027,028,029
     27         * 号码：七位或八位
     28         */
    // NSString * PHS = @"^0(10|2[0-5789]|\\d{3})\\d{7,8}$";
    
    NSPredicate *regextestmobile = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", MOBILE];
    NSPredicate *regextestcm = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CM];
    NSPredicate *regextestcu = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CU];
    NSPredicate *regextestct = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CT];
    
    if (([regextestmobile evaluateWithObject:self] == YES)
        || ([regextestcm evaluateWithObject:self] == YES)
        || ([regextestct evaluateWithObject:self] == YES)
        || ([regextestcu evaluateWithObject:self] == YES))
    {
        return YES;
    }
    else
    {
        return NO;
    }
}

+ (BOOL)validateIDCardNumber:(NSString *)value {
    value = [value stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    NSUInteger length = 0;
    if (!value) {
        return NO;
    }else {
        length = value.length;
        
        if (length !=15 && length !=18) {
            return NO;
        }
    }
    // 省份代码
    NSArray *areasArray =@[@"11",@"12", @"13",@"14", @"15",@"21", @"22",@"23", @"31",@"32", @"33",@"34", @"35",@"36", @"37",@"41", @"42",@"43", @"44",@"45", @"46",@"50", @"51",@"52", @"53",@"54", @"61",@"62", @"63",@"64", @"65",@"71", @"81",@"82", @"91"];
    
    NSString *valueStart2 = [value substringToIndex:2];
    BOOL areaFlag =NO;
    for (NSString *areaCode in areasArray) {
        if ([areaCode isEqualToString:valueStart2]) {
            areaFlag = YES;
            break;
        }
    }
    
    if (!areaFlag) {
        return false;
    }
    
    
    NSRegularExpression *regularExpression;
    NSUInteger numberofMatch;
    
    int year =0;
    switch (length) {
        case 15:
            year = [value substringWithRange:NSMakeRange(6,2)].intValue +1900;
            
            if (year %4 ==0 || (year %100 ==0 && year %4 ==0)) {
                
                regularExpression = [[NSRegularExpression alloc]initWithPattern:@"^[1-9][0-9]{5}[0-9]{2}((01|03|05|07|08|10|12)(0[1-9]|[1-2][0-9]|3[0-1])|(04|06|09|11)(0[1-9]|[1-2][0-9]|30)|02(0[1-9]|[1-2][0-9]))[0-9]{3}$"
                                                                       options:NSRegularExpressionCaseInsensitive
                                                                         error:nil];//测试出生日期的合法性
            }else {
                regularExpression = [[NSRegularExpression alloc]initWithPattern:@"^[1-9][0-9]{5}[0-9]{2}((01|03|05|07|08|10|12)(0[1-9]|[1-2][0-9]|3[0-1])|(04|06|09|11)(0[1-9]|[1-2][0-9]|30)|02(0[1-9]|1[0-9]|2[0-8]))[0-9]{3}$"
                                                                       options:NSRegularExpressionCaseInsensitive
                                                                         error:nil];//测试出生日期的合法性
            }
            numberofMatch = [regularExpression numberOfMatchesInString:value
                                                              options:NSMatchingReportProgress
                                                                range:NSMakeRange(0, value.length)];
            
            
            if(numberofMatch >0) {
                return YES;
            }else {
                return NO;
            }
        case 18:
            
            year = [value substringWithRange:NSMakeRange(6,4)].intValue;
            if (year %4 ==0 || (year %100 ==0 && year %4 ==0)) {
                
                regularExpression = [[NSRegularExpression alloc]initWithPattern:@"^[1-9][0-9]{5}(19|20)[0-9]{2}((01|03|05|07|08|10|12)(0[1-9]|[1-2][0-9]|3[0-1])|(04|06|09|11)(0[1-9]|[1-2][0-9]|30)|02(0[1-9]|[1-2][0-9]))[0-9]{3}[0-9Xx]$"
                                                                       options:NSRegularExpressionCaseInsensitive
                                                                         error:nil];//测试出生日期的合法性
            }else {
                regularExpression = [[NSRegularExpression alloc]initWithPattern:@"^[1-9][0-9]{5}(19|20)[0-9]{2}((01|03|05|07|08|10|12)(0[1-9]|[1-2][0-9]|3[0-1])|(04|06|09|11)(0[1-9]|[1-2][0-9]|30)|02(0[1-9]|1[0-9]|2[0-8]))[0-9]{3}[0-9Xx]$"
                                                                       options:NSRegularExpressionCaseInsensitive
                                                                         error:nil];//测试出生日期的合法性
            }
            numberofMatch = [regularExpression numberOfMatchesInString:value
                                                              options:NSMatchingReportProgress
                                                                range:NSMakeRange(0, value.length)];
            
            
            if(numberofMatch >0) {
                int S = ([value substringWithRange:NSMakeRange(0,1)].intValue + [value substringWithRange:NSMakeRange(10,1)].intValue) *7 + ([value substringWithRange:NSMakeRange(1,1)].intValue + [value substringWithRange:NSMakeRange(11,1)].intValue) *9 + ([value substringWithRange:NSMakeRange(2,1)].intValue + [value substringWithRange:NSMakeRange(12,1)].intValue) *10 + ([value substringWithRange:NSMakeRange(3,1)].intValue + [value substringWithRange:NSMakeRange(13,1)].intValue) *5 + ([value substringWithRange:NSMakeRange(4,1)].intValue + [value substringWithRange:NSMakeRange(14,1)].intValue) *8 + ([value substringWithRange:NSMakeRange(5,1)].intValue + [value substringWithRange:NSMakeRange(15,1)].intValue) *4 + ([value substringWithRange:NSMakeRange(6,1)].intValue + [value substringWithRange:NSMakeRange(16,1)].intValue) *2 + [value substringWithRange:NSMakeRange(7,1)].intValue *1 + [value substringWithRange:NSMakeRange(8,1)].intValue *6 + [value substringWithRange:NSMakeRange(9,1)].intValue *3;
                int Y = S %11;
                NSString *M =@"F";
                NSString *JYM =@"10X98765432";
                M = [JYM substringWithRange:NSMakeRange(Y,1)];// 判断校验位
                if ([M isEqualToString:[value substringWithRange:NSMakeRange(17,1)]]) {
                    return YES;// 检测ID的校验位
                }else {
                    return NO;
                }
                
            }else {
                return NO;
            }
        default:
            return NO;
    }
}

- (BOOL)isValidateEmail
{
    if ([self length]<1) {
        return NO;
    }
    NSString *emailCheck = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",emailCheck];
    return [emailTest evaluateWithObject:self];
}

@end


@implementation UIFont (wb)
+(UIFont *)appFontOfSize:(CGFloat)size
{
    return [UIFont fontWithName:@"RTWSYueRoudGoDemo-Regular" size:size];
}
@end