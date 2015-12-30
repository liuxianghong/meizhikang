//
//  IMConnect.m
//  meizhikang
//
//  Created by 刘向宏 on 15/12/9.
//  Copyright © 2015年 刘向宏. All rights reserved.
//

#import "IMConnect.h"
#import "GCDAsyncUdpSocket.h"
#import "NSString+scisky.h"
#import "GCDAsyncSocket.h"
#import "IMObject.h"
#import "JSONKit.h"
#import "meizhikang-Swift.h"
#import <MagicalRecord/MagicalRecord.h>

//IM系统地址182.150.44.21，端口9527
//数据上传系统鉴权地址182.150.44.21，端口9529
//数据上传系统上传服务器地址由鉴权协议返回，目前应该是182.150.44.21，端口9530

#define IMIP @"182.150.44.21"//@"182.150.44.21"
//@"192.168.16.102"//
#define IMPORT 9527

@implementation IMConnect
{
    GCDAsyncSocket *asyncSocket;
    long connectTag;
    IMObject *currentIM;
    IMObject *reciveIM;
    NSData *tokenIMConnect;
    NSData *passWordIMConnect;
    NSString *loginName;
    NSString *loginPassWord;
    Byte key[16];
    NSTimer *countDownTimer;
    NSMutableArray *IMQueue;
    BOOL isListen;
    BOOL isLogin;
}

+(instancetype)Instance
{
    static id _sharedInstance = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        _sharedInstance = [[self alloc] init];
    });
    return _sharedInstance;
}

-(id)init
{
    self = [super init];
//    udpSocket = [[GCDAsyncUdpSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
    //connectDic = [[NSMutableDictionary alloc] init];
    IMQueue = [[NSMutableArray alloc]init];
    [self setudpSocket];
    isListen = NO;
    isLogin = NO;
    countDownTimer = [NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(countDown) userInfo:nil repeats:YES];
    return self;
}

-(void)countDown
{
    if(isLogin && asyncSocket.isConnected && tokenIMConnect && passWordIMConnect && !(currentIM && currentIM.sendingType == IMObjectSending)){
        NSUInteger size = 14+8;
        long tag = ++connectTag;
        Byte *CommandStructure = malloc(size);
        [self setsenderHead:CommandStructure cmd:0x87 type:0x0 length:0 tag:tag token:tokenIMConnect];
        NSData *data = [NSData dataWithBytes:CommandStructure length:size];
        
        [self writeData:data tag:tag readHead:^UInt32(UInt32 lenth_) {
            return 0;
        } completion:^(NSData *data) {
            
        } failure:^(NSError *error) {
        }];
        free(CommandStructure);
    }
}

- (void)setudpSocket
{
    if (!asyncSocket) {
        dispatch_queue_t mainQueue = dispatch_get_main_queue();
        asyncSocket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:mainQueue];
    }
    else
    {
        //[asyncSocket disconnect];
    }
    
    if (![asyncSocket isConnected]) {
        NSString *host = IMIP;
        uint16_t port = IMPORT;
        NSError *error = nil;
        if (![asyncSocket connectToHost:host onPort:port error:&error])
        {
            NSLog(@"无法建立连接");
        }
    }
}

-(void)LoginOut{
    isLogin = NO;
    [asyncSocket disconnect];
    NSTimeInterval time = [NSDate date].timeIntervalSince1970;
    while([NSDate date].timeIntervalSince1970 - time < 0.1){
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
    }
}

-(BOOL)isLogin{
    return isLogin;
}

-(void)setsenderHead:(Byte *)CommandStructure cmd:(Byte)cmd type:(Byte)type length:(NSUInteger)length tag:(long)tag{
    UInt32 magic = IM_MAGIC;
    memcpy(CommandStructure, &magic, 4);
    CommandStructure[4] = cmd;
    CommandStructure[5] = type;
    memcpy(CommandStructure+6, &tag, 4);
    memcpy(CommandStructure+10, &length, 4);
}

-(void)setsenderHead:(Byte *)CommandStructure cmd:(Byte)cmd type:(Byte)type length:(NSUInteger)length tag:(long)tag token:(NSData *)token{
    UInt32 magic = IM_MAGIC;
    memcpy(CommandStructure, &magic, 4);
    CommandStructure[4] = cmd;
    CommandStructure[5] = type;
    memcpy(CommandStructure+6, &tag, 4);
    memcpy(CommandStructure+10, [token bytes], 8);
    memcpy(CommandStructure+10+8, &length, 4);
}


-(void)getToken:(NSString *)userName completion:(IMObjectTokenCompletionHandler)completion failure:(IMObjectFailureHandler)failure
{
    NSData *data2 = [userName AESEncrypt];
    
    NSUInteger size = 14+[data2 length];
    long tag = ++connectTag;
    NSUInteger length = 16;
    
    Byte *CommandStructure = malloc(size);
    [self setsenderHead:CommandStructure cmd:0x86 type:0x1 length:length tag:tag];

    memcpy(CommandStructure+14, [data2 bytes], [data2 length]);
    
    NSData *data = [NSData dataWithBytes:CommandStructure length:size];
    [self writeData:data tag:tag readHead:^UInt32(UInt32 lenth_) {
        if (lenth_ == 0) {
            return 0;
        }
        return 8+16;
    } completion:^(NSData *data) {
        if ([data length]<18) {
            failure([NSError errorWithDomain:@"服务器返回失败" code:0 userInfo:nil]);
        }
        else
        {
            NSData *token = [NSData dataWithBytes:[data bytes]+10 length:8];
            loginName = userName;
            completion(token,nil);
        }
    } failure:failure];
    free(CommandStructure);
}

-(NSData *)getTextBody:(NSString *)body{
    //NSLog(@"%@",body);
    NSData *dat = [body dataUsingEncoding:NSUTF8StringEncoding];
    NSUInteger length = [dat length];
    NSUInteger size = 12 + length;
    char *CommandStructure = malloc(size);
    bzero(CommandStructure, size);
    CommandStructure[0] = 0x1;
    CommandStructure[1] = 0x0;
    CommandStructure[6] = 0x1;
    CommandStructure[7] = 0x1;
    memcpy(CommandStructure+8, &length, 4);
    memcpy(CommandStructure+12, [dat bytes], length);
    NSData *data = [NSData dataWithBytes:CommandStructure length:size];
    free(CommandStructure);
    return data;
}

-(NSData *)getFileBody:(NSData *)file uuid:(UInt32)uuid fileTye:(NSInteger)fileTye {
    //NSLog(@"%@",file);
    NSUInteger length = sizeof(uuid) + [file length];
    NSUInteger size = 12 + length;
    char *CommandStructure = malloc(size);
    bzero(CommandStructure, size);
    CommandStructure[0] = 0x1;
    CommandStructure[1] = 0x0;
    CommandStructure[6] = 0x2;
    CommandStructure[7] = fileTye;
    memcpy(CommandStructure+8, &length, 4);
    memcpy(CommandStructure+12, &uuid, sizeof(uuid));
    memcpy(CommandStructure+12+sizeof(uuid), [file bytes], [file length]);
    NSData *data = [NSData dataWithBytes:CommandStructure length:size];
    free(CommandStructure);
    return data;
}

+ (NSData *)dataFromHexString:(NSString *)hexString { //
    
    char *myBuffer = (char *)malloc((int)[hexString length] / 2 + 1);
    bzero(myBuffer, [hexString length] / 2 + 1);
    for (int i = 0; i < [hexString length] - 1; i += 2) {
        unsigned int anInt;
        NSString * hexCharStr = [hexString substringWithRange:NSMakeRange(i, 2)];
        NSScanner * scanner = [[NSScanner alloc] initWithString:hexCharStr];
        [scanner scanHexInt:&anInt];
        myBuffer[i / 2] = (char)anInt;
    }
    NSData *unicodeString = [NSData dataWithBytes:myBuffer length:[hexString length] / 2 + 1];
    free(myBuffer);
    return unicodeString;
}

-(void)test:(NSData *)token{
    
    __unused long tag = ++connectTag;
   
}


-(void)login:(NSString *)pw withToken:(NSData *)token completion:(IMObjectLoginHandler)completion failure:(IMObjectFailureHandler)failure
{
    NSData *pwDataf = [pw getPassWord];
    tokenIMConnect = token;
    passWordIMConnect = pwDataf;
    NSData *data2 = [NSString AESAndXOREncrypt:token data:passWordIMConnect];
    
    NSUInteger size = 14+[token length]+[data2 length];
    long tag = ++connectTag;
    NSUInteger length = 8+16;
    Byte *CommandStructure = malloc(size);
    
    [self setsenderHead:CommandStructure cmd:0x86 type:0x2 length:length tag:tag];
    memcpy(CommandStructure+14, [token bytes], [token length]);
    memcpy(CommandStructure+14 + [token length], [data2 bytes], [data2 length]);
    
    NSData *data = [NSData dataWithBytes:CommandStructure length:size];
    
    [self writeData:data tag:tag readHead:^UInt32(UInt32 lenth_) {
        return 0;
    } completion:^(NSData *data) {
        UInt32 ip = 0;
        UInt16 port = 0;
        isLogin = YES;
        loginPassWord = pw;
        completion(ip,port);
    } failure:failure];
    free(CommandStructure);
}


-(void)getRegistToken:(NSString *)userName completion:(IMObjectTokenCompletionHandler)completion failure:(IMObjectFailureHandler)failure{
    NSData *data2 = [userName AESEncrypt];
    
    NSUInteger size = 14+[data2 length];
    long tag = ++connectTag;
    NSUInteger length = 16;//0x10;
    Byte *CommandStructure = malloc(size);
    [self setsenderHead:CommandStructure cmd:0x86 type:0x3 length:length tag:tag];
    
    memcpy(CommandStructure+14, [data2 bytes], [data2 length]);
    
    NSData *data = [NSData dataWithBytes:CommandStructure length:size];
    [self writeData:data tag:tag readHead:^UInt32(UInt32 lenth_) {
        if (lenth_ == 0) {
            return 0;
        }
        else
        {
            UInt32 ll = ((lenth_-8)/16+1)*16+8;
            NSLog(@"长度 ：%d,我的长度: %d",lenth_,ll);
            return ll;
        }
    } completion:^(NSData *data) {
        NSData *token = [NSData dataWithBytes:[data bytes]+10 length:8];
        completion(token,nil);
    } failure:failure];
    free(CommandStructure);
}

-(void)getResetPWToken:(NSString *)userName completion:(IMObjectTokenCompletionHandler)completion failure:(IMObjectFailureHandler)failure{
    NSData *data2 = [userName AESEncrypt];
    
    NSUInteger size = 14+[data2 length];
    long tag = ++connectTag;
    NSUInteger length = 16;//0x10;
    Byte *CommandStructure = malloc(size);
    [self setsenderHead:CommandStructure cmd:0x86 type:0x7 length:length tag:tag];
    
    memcpy(CommandStructure+14, [data2 bytes], [data2 length]);
    
    NSData *data = [NSData dataWithBytes:CommandStructure length:size];
    [self writeData:data tag:tag readHead:^UInt32(UInt32 lenth_) {
        if (lenth_ == 0) {
            return 0;
        }
        else
        {
            UInt32 ll = ((lenth_-8)/16+1)*16+8;
            return ll;
        }
    } completion:^(NSData *data) {
        tokenIMConnect = [NSData dataWithBytes:[data bytes]+10 length:8];
        NSData *imageData = [NSData dataWithBytes:[data bytes]+18 length:([data length]-18)];
        NSLog(@"imageData : %@",imageData);
        imageData = [NSString AESAndXORDecrypt:tokenIMConnect data:imageData];
        completion(tokenIMConnect,imageData);
    } failure:failure];
    free(CommandStructure);
}

-(void)getCode:(NSString *)phoenName code:(NSString *)code completion:(IMObjectTokenCompletionHandler)completion failure:(IMObjectFailureHandler)failure{
    Byte body[24] = {0};
    NSData *phoneData = [phoenName dataUsingEncoding:NSASCIIStringEncoding];
    memcpy(body,[phoneData bytes],[phoneData length]);
    NSData *codeData = [code dataUsingEncoding:NSASCIIStringEncoding];
    memcpy(body+16,[codeData bytes],[codeData length]);
    
    NSData *ddd = [NSData dataWithBytes:body length:24];
    NSLog(@"%@",ddd);
    
    NSData *data2 = [NSString AESAndXOREncrypt:tokenIMConnect data:ddd];
    long tag = ++connectTag;
    NSUInteger length = 8+16+8;
    NSUInteger size = 14+8+[data2 length];
    Byte *CommandStructure = malloc(size);
    [self setsenderHead:CommandStructure cmd:0x86 type:0x8 length:length tag:tag];
    
    memcpy(CommandStructure+14, [tokenIMConnect bytes], [tokenIMConnect length]);
    memcpy(CommandStructure+14+8, [data2 bytes], [data2 length]);
    
    
    NSData *data = [NSData dataWithBytes:CommandStructure length:size];
    NSLog(@"%@",data);
    [self writeData:data tag:tag readHead:^UInt32(UInt32 lenth_) {
        return 0;
    } completion:^(NSData *data) {
        completion(nil,0);
    } failure:failure];
    free(CommandStructure);
}

-(void)registWithToken:(NSData *)token withCode:(NSString *)code withNickName:(NSString *)nickName withPW:(NSString *)pw withSex:(UInt8)sex withAge:(UInt8)age withHeiht:(UInt8)height withWight:(UInt16)wight completion:(void (^)())completion failure:(IMObjectFailureHandler)failure{
    
    Byte body[8+16+16+1+1+2];
    bzero(body, sizeof(body));
    
    NSData *codeData = [code dataUsingEncoding:NSUTF8StringEncoding];
    memcpy(body, [codeData bytes], [codeData length]);
    
    NSData *nickNameData = [nickName dataUsingEncoding:NSUTF8StringEncoding];
    memcpy(body+8, [nickNameData bytes], [nickNameData length]);
    
    NSData *pwDataf = [pw getPassWord];
    tokenIMConnect = token;
    passWordIMConnect = pwDataf;
    NSLog(@"密码 %@",passWordIMConnect);
    memcpy(body+8+16, [passWordIMConnect bytes], [passWordIMConnect length]);
    
    UInt8 sexAndAhe = (sex<<7) + age;
    memcpy(body+8+16+16, &sexAndAhe, 1);
    memcpy(body+8+16+16+1, &height, 1);
    
    memcpy(body+8+16+16+2, &wight, 2);
    
    NSData *bodyData = [NSData dataWithBytes:body length:sizeof(body)];
    NSData *dataBody = [NSString AESAndXOREncrypt:token data:bodyData];
    
    NSUInteger size = 14+[token length]+[dataBody length];
    long tag = ++connectTag;
    NSUInteger length = sizeof(body) + 8;//0x10;
    Byte *CommandStructure = malloc(size);
    [self setsenderHead:CommandStructure cmd:0x86 type:0x4 length:length tag:tag];
   
    memcpy(CommandStructure+14, [token bytes], [token length]);
    memcpy(CommandStructure+14+8, [dataBody bytes], [dataBody length]);
    
    NSData *data = [NSData dataWithBytes:CommandStructure length:size];
    [self writeData:data tag:tag readHead:^UInt32(UInt32 lenth_) {
        return 0;
    } completion:completion failure:failure];
    free(CommandStructure);
    
}


-(void)RequstUserInfo:(NSDictionary *)dic completion:(void (^)(id info))completion failure:(IMObjectFailureHandler)failure{
    
    long tag = ++connectTag;
    
    NSData *body = [self getTextBody:[dic JSONString]];
    NSUInteger length = [body length];
    
    
    oxrPWToken(key,[tokenIMConnect bytes]+4,[passWordIMConnect bytes]);
    
    NSData *eBady = [NSString encryptWithAESkey:key data:body];
    NSUInteger size = 14+8+[eBady length];
    Byte *CommandStructure = malloc(size);
    [self setsenderHead:CommandStructure cmd:0x87 type:0x1 length:length tag:tag token:tokenIMConnect];
    memcpy(CommandStructure+14 + 8, [eBady bytes], [eBady length]);
    
    NSData *data = [NSData dataWithBytes:CommandStructure length:size];
    
    
    [self writeData:data tag:tag readHead:^UInt32(UInt32 _lenth) {
        if (_lenth == 0) {
            return 0;
        }
        return (_lenth/16+1)*16;
    } completion:^(NSData *data) {
        if ([data length]<10) {
            failure([NSError errorWithDomain:@"服务器返回失败" code:0 userInfo:nil]);
        }
        else{
            NSData *dddd = [NSData dataWithBytes:[data bytes]+10 length:([data length]-10)];
            NSData *data2 = [NSString decryptWithAES:dddd withKey:key];
            if (data2.length <12) {
                failure([NSError errorWithDomain:@"服务器返回失败" code:0 userInfo:nil]);
            }
            else
            {
                NSData *dddd2 = [NSData dataWithBytes:[data2 bytes]+12 length:([data2 length]-12)];
                id object = [dddd2 objectFromJSONData];
                completion(object);
            }
        }
        
    } failure:failure];
    free(CommandStructure);
}

-(void)UpLoadFileRequst:(NSData *)fileData fileType:(NSInteger)fileType uuid:(UInt32)uuid completion:(void (^)(id info))completion failure:(IMObjectFailureHandler)failure{
    
    long tag = ++connectTag;
    
    NSData *body = [self getFileBody:fileData uuid:uuid fileTye:fileType];
    NSUInteger length = [body length];
    
    oxrPWToken(key,[tokenIMConnect bytes]+4,[passWordIMConnect bytes]);
    
    NSData *eBady = [NSString encryptWithAESkey:key data:body];
    NSUInteger size = 14+8+[eBady length];
    Byte *CommandStructure = malloc(size);
    [self setsenderHead:CommandStructure cmd:0x87 type:0x1 length:length tag:tag token:tokenIMConnect];
    memcpy(CommandStructure+14 + 8, [eBady bytes], [eBady length]);
    
    NSData *data = [NSData dataWithBytes:CommandStructure length:size];
    
    
    [self writeData:data tag:tag readHead:^UInt32(UInt32 _lenth) {
        if (_lenth == 0) {
            return 0;
        }
        return (_lenth/16+1)*16;
    } completion:^(NSData *data) {
        NSData *dddd = [NSData dataWithBytes:[data bytes]+10 length:([data length]-10)];
        NSData *data2 = [NSString decryptWithAES:dddd withKey:key];
        NSData *dddd2 = [NSData dataWithBytes:[data2 bytes]+12 length:([data2 length]-12)];
        id object = [dddd2 objectFromJSONData];
        completion(object);
    } failure:failure];
    free(CommandStructure);
}

-(void)UploadFileRequst:(NSData *)file fileType:(IMMsgSendFileType)fieType fromType:(IMMsgSendFromType)fromtype toid:(NSNumber *)toid completion:(void (^)(id info))completion failure:(IMObjectFailureHandler)failure{
    
    UInt32 uuid = [NSDate date].timeIntervalSince1970;
    NSDictionary *dic = @{@"type" : @"authorize" ,
                          @"uuid" : @(uuid) ,
                          @"fromtype" : @(fromtype) ,
                          @"toid" : toid
                          };
    [[IMConnect Instance] RequstUserInfo:dic completion:^(id info) {
        if ([info[@"flag"] integerValue] == 1) {
            [self UpLoadFileRequst:file fileType:fieType uuid:uuid completion:completion failure:failure];
        }
        else
        {
            failure([NSError errorWithDomain:@"授权失败" code:0 userInfo:nil]);
        }
        
    } failure:failure];
    
}

-(void)writeData:(NSData *)data tag:(long)tag readHead:(IMObjectReadHeadHandler)readHead completion:(IMObjectCompletionHandler)completion failure:(IMObjectFailureHandler)failure{
    [self setudpSocket];
    if (tag==-1) {
        [asyncSocket writeData:data withTimeout:IMTIMEOUT tag:tag];
    }
    else
    {
        IMObject *im = [[IMObject alloc]initWithTag:tag];
        im.readHead = readHead;
        im.completion = completion;
        im.failure = failure;
        im.lenth = 10;
        if (currentIM && currentIM.sendingType != IMObjectSendFinished) {
            im.sendData = data;
            [IMQueue addObject:im];
        }
        else
        {
            currentIM = im;
            currentIM.sendingType = IMObjectSending;
            [asyncSocket writeData:data withTimeout:IMTIMEOUT tag:tag];
        }
    }
    
}

-(void)listenHeadDataWithIMObject:(IMObject *)im{
    
    [self listenData:10 Withtag:im.tag];
}

-(void)listenData:(NSInteger)length WithIMObject:(IMObject *)im{
    im.lenth = length;
    [self listenData:length Withtag:im.tag];
}

-(void)listenData:(NSInteger)length Withtag:(long)tag{
    [asyncSocket readDataToLength:length withTimeout:IMTIMEOUT tag:tag];
}

-(void)listenRecive{
    if (currentIM && currentIM.sendingType != IMObjectSendFinished)
    {
        return;
    }
    if (reciveIM) {
        currentIM.sendingType = IMObjectSendFinished;
        reciveIM = nil;
    }
    NSMutableArray *array = [[NSMutableArray alloc]init];
    for (int i=0; i<IMQueue.count; i++) {
        IMObject *im = IMQueue.firstObject;
        if (im.sendingType == IMObjectSendFinished){
            [array addObject:im];
        }
    }
    [IMQueue removeObjectsInArray:array];
    if (IMQueue.count==0) {
        isListen = YES;
        [asyncSocket readDataToLength:10 withTimeout:-1 tag:0];
    }
    else{
        currentIM = IMQueue.firstObject;
        currentIM.sendingType = IMObjectSending;
        [IMQueue removeObject:currentIM];
        [asyncSocket writeData:currentIM.sendData withTimeout:IMTIMEOUT tag:currentIM.tag];
    }
}

- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(UInt16)port
{
    NSLog(@"didConnectToHost");
    //[self listenData];
}

- (void)socketDidSecure:(GCDAsyncSocket *)sock
{
    NSLog(@"socketDidSecure");
}

- (void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag
{
    NSLog(@"socket:%p didWriteDataWithTag:%ld", sock, tag);
    if (!isListen && tag != -1) {
        [self listenHeadDataWithIMObject:currentIM];
    }
    //[self listenData];
}

- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
    NSLog(@"didReadData%@",data);
    
    if (tag == 0) {
        isListen = false;
    }
    
    if(data.length==10){
        UInt32 magic = 0;
        memcpy(&magic, [data bytes], sizeof(magic));
        if (magic == IM_MAGIC) {
            UInt8 cmd = 0;
            UInt8 subcmd = 0;
            UInt32 reciveTag = 0;
            memcpy(&cmd, [data bytes]+4, sizeof(cmd));
            memcpy(&subcmd, [data bytes]+5, sizeof(subcmd));
            memcpy(&reciveTag, [data bytes]+6, sizeof(reciveTag));
            if (cmd == 0x88) {
                reciveIM = [[IMObject alloc]initWithTag:tag];
                reciveIM.cmd = cmd;
                reciveIM.subCmd = subcmd;
                reciveIM.tag = reciveTag;
                reciveIM.sendingType = IMObjectSending;
                [reciveIM.data appendData:data];
                [self listenData:12 Withtag:tag];
            }
            else
            {
                [self doSocketError];
            }
            return;
        }
    }
    
    if ((reciveIM && reciveIM.sendingType != IMObjectSendFinished)) {
        if(reciveIM.cmd == 0x88)
        {
            [self imRecivePostMessage:data];
        }
        else{
            [self doSocketError];
        }
        return;
    }
    
    
    
    IMObject *im = currentIM;
    if (!im || im.sendingType != IMObjectSending) {//不是0x88推送 也不是发送返回
        [self doSocketError];
        return;
    }
    if (im.lenth != [data length]) {
        currentIM.sendingType = IMObjectSendFinished;
        im.failure([NSError errorWithDomain:@"Read data error" code:0 userInfo:nil]);
        [self listenRecive];
        return;
    }
    if ([im.data length] == 0) {
        if ([data length]<10) {
            [self doSocketError];
            return;
        }
        UInt8 code = 0;
        UInt32 length = 0;
        UInt32 seq = 0;
        memcpy(&code, [data bytes]+1, sizeof(code));
        memcpy(&seq, [data bytes]+2, sizeof(seq));
        memcpy(&length, [data bytes]+6, sizeof(length));
        if ((long)seq != im.tag) {
            im.failure([NSError errorWithDomain:@"服务器出错" code:0 userInfo:nil]);
            currentIM.sendingType = IMObjectSendFinished;
            [self doSocketError];
            return;
        }
        [im.data appendData:data];
        length = currentIM.readHead(length);
        if (length == 0) {
            currentIM.sendingType = IMObjectSendFinished;
            if (code != 200) {
                im.failure([NSError errorWithDomain:[NetWorkingContents getReturnDescription:code] code:code userInfo:nil]);
            }
            else{
                im.completion(im.data);
            }
            [self listenRecive];
        }
        else
        {
            [self listenData:length WithIMObject:im];
            return;
        }
    }
    else
    {
        currentIM.sendingType = IMObjectSendFinished;
        [im.data appendData:data];
        im.completion(im.data);
        [self listenRecive];
    }
    
    
}

- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err
{
    
    NSLog(@"socket: DidDisconnect:%p withError: %@", sock, err);
    isListen = false;
    if (!err) {
        err = [NSError errorWithDomain:@"已和服务器断开连接" code:0 userInfo:nil];
    }
    
    if (isLogin) {
        [[IMConnect Instance] getToken:loginName completion:^(NSData *token, NSData *data) {
            [[IMConnect Instance] login:loginPassWord withToken:token completion:^(UInt32 ip, UInt16 port) {
                if (currentIM && currentIM.sendingType != IMObjectSendFinished) {
                    [self writeData:currentIM.sendData tag:currentIM.tag readHead:currentIM.readHead completion:currentIM.completion failure:currentIM.failure];
                }
            } failure:^(NSError *error) {
            }];
        } failure:^(NSError *error) {
        }];
    }
    else
    {
        if (currentIM && currentIM.sendingType != IMObjectSendFinished) {// err &&
            currentIM.sendingType = IMObjectSendFinished;
            currentIM.failure([NSError errorWithDomain:err.localizedDescription code:0 userInfo:nil]);
        }
        for (IMObject *im in IMQueue) {
            if (im.sendingType != IMObjectSendFinished) {
                im.sendingType = IMObjectSendFinished;
                im.failure([NSError errorWithDomain:err.localizedDescription code:0 userInfo:nil]);
            }
        }
        if (reciveIM) {
            reciveIM = nil;
        }
        [IMQueue removeAllObjects];
    }
    
    
}

-(void)imRecivePostMessage:(NSData *)data{
    [reciveIM.data appendData:data];
    if (reciveIM.data.length<22) {
        [self doSocketError];
        return;
    }
    else if (reciveIM.data.length == 22) {
        UInt32 length = 0;
        memcpy(&length, [data bytes]+8, sizeof(length));
        if(length == 0){
            [self listenRecive];
        }
        else{
            length = (length/16+1)*16;
            [self listenData:length Withtag:reciveIM.tag];
        }
    }
    else{
        Byte token[8];
        memcpy(token, [reciveIM.data bytes]+10, 8);
        Byte newKey[16];
        oxrPWToken(newKey,token+4,[passWordIMConnect bytes]);
        NSData *dddd = [NSData dataWithBytes:[reciveIM.data bytes]+22 length:([reciveIM.data length]-22)];
        NSData *data2 = [NSString decryptWithAES:dddd withKey:newKey];
        if (reciveIM.subCmd == 0xfe) {
            
            NSString *str = [[NSString alloc] initWithData:data2 encoding:NSUTF8StringEncoding];
            [[NSNotificationCenter defaultCenter]
             postNotificationName:@"loginOutNotification" object:str];
            [self LoginOut];
        }
        else if (reciveIM.subCmd == 0x1){
            
            if ([data2 length]<12) {
                [self doSocketError];
                return;
            }
            NSData *dddd2 = [NSData dataWithBytes:[data2 bytes]+12 length:([data2 length]-12)];
            id object = [dddd2 objectFromJSONData];
            NSLog(@"%@",object);
            if (object){
                if ([object[@"pushtype"] isEqualToString:@"meet"] ) {
                    Message *message = [Message MR_createEntity];
                    dispatch_async(dispatch_get_global_queue(0, 0), ^{
                        [message upDateMessageInfo:object];
                        [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
                        [[NSNotificationCenter defaultCenter]
                         postNotificationName:@"reciveMessageNotification" object:message];
                    });
                    
                }
                else if ([object[@"pushtype"] isEqualToString:@"email"] ) {
                    Email *email = [Email EmailByUuid:object[@"uuid"]];
                    [email upDateEmailInfo:object];
                    [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
                    [[NSNotificationCenter defaultCenter]
                     postNotificationName:@"reciveEmailNotification" object:nil];
                }
                else if ([object[@"pushtype"] isEqualToString:@"group_change"]){
                    [[UserInfo CurrentUser] loadGrous];
                }
                else{
                    NSLog(@"unknow pushtype");
                }
            }
            
            NSUInteger size = 14;
            Byte *CommandStructure = malloc(size);
            [self setsenderHead:CommandStructure cmd:0x98 type:reciveIM.subCmd length:0 tag:reciveIM.tag];
            NSData *data = [NSData dataWithBytes:CommandStructure length:size];
            
            [self writeData:data tag:-1 readHead:nil completion:nil failure:nil];
            free(CommandStructure);
            
        }
        [self listenRecive];
    }
}

-(void)doSocketError{
    [asyncSocket disconnect];
    NSLog(@"####################### doSocketError ############################");
}

@end
