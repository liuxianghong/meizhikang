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

//IM系统地址182.150.44.21，端口9527
//数据上传系统鉴权地址182.150.44.21，端口9529
//数据上传系统上传服务器地址由鉴权协议返回，目前应该是182.150.44.21，端口9530

#define IMIP @"182.150.44.21"//@"182.150.44.21"
//@"192.168.16.102"//
#define IMPORT 9527

@implementation IMConnect
{
    //GCDAsyncUdpSocket* udpSocket;
    
    GCDAsyncSocket *asyncSocket;
    
    long connectTag;
    
    IMObject *currentIM;
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
    [self setudpSocket];
    return self;
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
    
    NSString *host = IMIP;
    uint16_t port = IMPORT;
    NSError *error = nil;
    if (![asyncSocket connectToHost:host onPort:port error:&error])
    {
        NSLog(@"无法建立连接");
    }

}



-(void)getToken:(NSString *)userName completion:(IMObjectTokenCompletionHandler)completion failure:(IMObjectFailureHandler)failure
{
    NSData *data2 = [userName AESEncrypt];
    
    UInt16 size = 14+[data2 length];
    char *CommandStructure = malloc(size);
    UInt32 magic = 0xbebaedfe;
    memcpy(CommandStructure, &magic, 4);
    CommandStructure[4] = 0x86;
    CommandStructure[5] = 0x1;
    long tag = ++connectTag;
    memcpy(CommandStructure+6, &tag, 4);
    NSUInteger length = 16;//0x10;
    memcpy(CommandStructure+10, &length, 4);
    memcpy(CommandStructure+14, [data2 bytes], [data2 length]);
    
    NSData *data = [NSData dataWithBytes:CommandStructure length:size];
    [self writeData:data tag:tag readHead:^long(long lenth) {
        return 8+16;
    } completion:^(NSData *data) {
        NSData *token = [NSData dataWithBytes:[data bytes]+10 length:8];
        UInt16 time = 0;
        memcpy(&time, [data bytes]+18, 2);
        completion(token,time);
    } failure:^(NSError *error) {
        failure(error);
    }];
    free(CommandStructure);
}

-(void)test{
    NSString *body = @"{\"type\":\"account\"}";
    NSData *dat = [body dataUsingEncoding:NSUTF8StringEncoding];
    NSUInteger length = [dat length];
    NSData *dd = [body AESEncrypt];
    //NSUInteger length2 = [NSString AESDecrypt:dat];
    UInt16 size = 12 + length;
    char *CommandStructure = malloc(size);
    UInt32 magic = 0xbebaedfe;
    memcpy(CommandStructure, &magic, 4);
    CommandStructure[0] = 0x1;
    CommandStructure[1] = 0x0;
    CommandStructure[6] = 0x1;
    CommandStructure[7] = 0x1;
    long tag = ++connectTag;
    
    memcpy(CommandStructure+8, &length, 4);
    memcpy(CommandStructure+12, [dat bytes], length);
    
    NSData *data = [NSData dataWithBytes:CommandStructure length:size];
    NSLog(@"test: %@",data);
    
    
    [self writeData:data tag:tag readHead:^long(long lenth) {
        return 10;
    } completion:^(NSData *data) {
        UInt32 ip = 0;
        UInt16 port = 0;
        memcpy(&ip, [data bytes]+10, 4);
        memcpy(&port, [data bytes]+14, 2);
    } failure:^(NSError *error) {
    }];
    [asyncSocket writeData:dd withTimeout:-1 tag:4];
}

- (void)portTest{
    NSString *data = [@{@"type" :@"gropus"} JSONString];
    size_t size = 2+4+1+1+4+[data length];
    char *send = calloc(size, sizeof(char));
    send[1] = 1;
    send[6] = 0x1;
    send[7] = 0x1;
    UInt16 length = (UInt16)[data length];
    memcpy(send + 8, &length, sizeof(UInt16));
    memcpy(send + 12, [data cStringUsingEncoding:NSUTF8StringEncoding], length);
    NSData *sendData = [NSData dataWithBytes:send length:length];
    NSLog(@"%@",sendData);
    long tag = ++connectTag;
    [self writeData:sendData tag:tag readHead:^long(long lenth) {
        return 0;
    } completion:^(NSData *data) {
        NSLog(@"comp");
    } failure:^(NSError *error) {
        NSLog(@"error");
    }];
}

-(void)login:(NSString *)pw withToken:(NSData *)token completion:(IMObjectLoginHandler)completion failure:(IMObjectFailureHandler)failure
{
    NSLog(@"token %@",token);
    NSData *pwData = [pw dataFromMD5];
    Byte md5pw[16];
    oxrMD5(md5pw, [pwData bytes]);
    NSData *pwDataf = [NSData dataWithBytes:md5pw length:16];
    NSData *data2 = [NSString AESAndXOREncrypt:token data:pwDataf];
    NSLog(@"密码 %@",pwDataf);
    NSLog(@"密码加密 %@",data2);
    
    UInt16 size = 14+8+16;
    char *CommandStructure = malloc(size);
    UInt32 magic = 0xbebaedfe;
    memcpy(CommandStructure, &magic, 4);
    CommandStructure[4] = 0x86;
    CommandStructure[5] = 0x2;
    long tag = ++connectTag;
    memcpy(CommandStructure+6, &tag, 4);
    NSUInteger length = 8+[pw length];
    memcpy(CommandStructure+10, &length, 4);
    memcpy(CommandStructure+14, [token bytes], [token length]);
    memcpy(CommandStructure+14 + [token length], [data2 bytes], [data2 length]);
    
    NSData *data = [NSData dataWithBytes:CommandStructure length:size];
    NSLog(@"密码鉴权请求总体 %@",data);
    
    [self writeData:data tag:tag readHead:^long(long lenth) {
        return 0;
    } completion:^(NSData *data) {
        UInt32 ip = 0;
        UInt16 port = 0;
        memcpy(&ip, [data bytes]+10, 4);
        memcpy(&port, [data bytes]+14, 2);
        completion(ip,port);
    } failure:^(NSError *error) {
        failure(error);
    }];
    free(CommandStructure);
}


-(void)getRegistToken:(NSString *)userName completion:(IMObjectTokenCompletionHandler)completion failure:(IMObjectFailureHandler)failure{
    NSData *data2 = [userName AESEncrypt];
    
    UInt16 size = 14+[data2 length];
    char *CommandStructure = malloc(size);
    UInt32 magic = 0xbebaedfe;
    memcpy(CommandStructure, &magic, 4);
    CommandStructure[4] = 0x86;
    CommandStructure[5] = 0x3;
    long tag = ++connectTag;
    memcpy(CommandStructure+6, &tag, 4);
    NSUInteger length = 16;//0x10;
    memcpy(CommandStructure+10, &length, 4);
    memcpy(CommandStructure+14, [data2 bytes], [data2 length]);
    
    NSData *data = [NSData dataWithBytes:CommandStructure length:size];
    [self writeData:data tag:tag readHead:^long(long lenth_) {
        long ll = ((lenth_-8)/16+1)*16+8;
        NSLog(@"长度 ：%ld,我的长度: %ld",lenth_,ll);
        return ll;
    } completion:^(NSData *data) {
        NSData *token = [NSData dataWithBytes:[data bytes]+10 length:8];
        UInt16 time = 0;
//        memcpy(&time, [data bytes]+18, 2);
        completion(token,time);
    } failure:^(NSError *error) {
        failure(error);
    }];
    free(CommandStructure);
}

-(void)registWithToken:(NSData *)token withCode:(NSString *)code withNickName:(NSString *)nickName withPW:(NSString *)pw withSex:(UInt8)sex withAge:(UInt8)age withHeiht:(UInt8)height withWight:(UInt16)wight completion:(void (^)())completion failure:(IMObjectFailureHandler)failure{
    
    Byte body[8+16+16+1+1+2];
    bzero(body, sizeof(body));
    
    NSData *codeData = [code dataUsingEncoding:NSUTF8StringEncoding];
    memcpy(body, [codeData bytes], [codeData length]);
    
    NSData *nickNameData = [nickName dataUsingEncoding:NSUTF8StringEncoding];
    memcpy(body+8, [nickNameData bytes], [nickNameData length]);
    
    NSData *pwData = [pw dataUsingEncoding:NSUTF8StringEncoding];
    memcpy(body+8+16, [pwData bytes], [pwData length]);
    
    UInt8 sexAndAhe = (sex<<7) + age;
    memcpy(body+8+16+16, &sexAndAhe, 1);
    memcpy(body+8+16+16+1, &height, 1);
    
    memcpy(body+8+16+16+2, &wight, 2);
    
    NSData *bodyData = [NSData dataWithBytes:body length:sizeof(body)];
    NSData *dataBody = [NSString AESAndXOREncrypt:token data:bodyData];
    
    UInt16 size = 14+[token length]+[dataBody length];
    char *CommandStructure = malloc(size);
    UInt32 magic = 0xbebaedfe;
    memcpy(CommandStructure, &magic, 4);
    CommandStructure[4] = 0x86;
    CommandStructure[5] = 0x4;
    long tag = ++connectTag;
    memcpy(CommandStructure+6, &tag, 4);
    NSUInteger length = sizeof(body) + 8;//0x10;
    memcpy(CommandStructure+10, &length, 4);
    memcpy(CommandStructure+14, [token bytes], [token length]);
    memcpy(CommandStructure+14+8, [dataBody bytes], [dataBody length]);
    
    NSData *data = [NSData dataWithBytes:CommandStructure length:size];
    [self writeData:data tag:tag readHead:^long(long lenth) {
        return 0;
    } completion:^(NSData *data) {
        completion();
    } failure:^(NSError *error) {
        failure(error);
    }];
    free(CommandStructure);
    
}

-(void)writeData:(NSData *)data tag:(long)tag readHead:(IMObjectReadHeadHandler)readHead completion:(IMObjectCompletionHandler)completion failure:(IMObjectFailureHandler)failure{
    //[self setudpSocket];
    currentIM = [[IMObject alloc]initWithTag:tag];
    currentIM.readHead = readHead;
    currentIM.completion = completion;
    currentIM.failure = failure;
    [asyncSocket writeData:data withTimeout:IMTIMEOUT tag:tag];
    
}

-(void)listenHeadDataWithIMObject:(IMObject *)im{
    im.lenth = 10;
    [asyncSocket readDataToLength:10 withTimeout:IMTIMEOUT tag:im.tag];
}

-(void)listenData:(NSInteger)length WithIMObject:(IMObject *)im{
    im.lenth = length;
    [asyncSocket readDataToLength:length withTimeout:IMTIMEOUT tag:im.tag];
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
    IMObject *im = currentIM;
    [self listenHeadDataWithIMObject:im];
    //[self listenData];
}

- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
    NSLog(@"didReadData%@",data);
    IMObject *im = currentIM;
    if (im.lenth != [data length]) {
        currentIM.finished = YES;
        im.failure([NSError errorWithDomain:@"Read data error" code:0 userInfo:nil]);
        return;
    }
    if ([im.data length] == 0) {
        [im.data appendData:data];
        long length = 0;
        memcpy(&length, [data bytes]+6, 4);
        UInt8 code = 0;
        memcpy(&code, [data bytes]+1, 1);
        if (code != 200) {
            currentIM.finished = YES;
            im.failure([NSError errorWithDomain:[NetWorkingContents getReturnDescription:code] code:code userInfo:nil]);
            return;
        }
        else{
            length = currentIM.readHead(length);
        }
        if (length == 0) {
            currentIM.finished = YES;
            im.completion(im.data);
        }
        else
        {
            [self listenData:length WithIMObject:im];
        }
    }
    else
    {
        currentIM.finished = YES;
        [im.data appendData:data];
        im.completion(im.data);
    }
    
}

- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err
{
    NSLog(@"socket: DidDisconnect:%p withError: %@", sock, err);
    if (currentIM && err) {
        currentIM.finished = YES;
        currentIM.failure(err);
    }
}
@end
