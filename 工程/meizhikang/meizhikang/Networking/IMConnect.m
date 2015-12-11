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
    //[self setudpSocket];
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
        [asyncSocket disconnect];
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
    NSUInteger length = [data2 length];//0x10;
    memcpy(CommandStructure+10, &length, 4);
    memcpy(CommandStructure+14, [data2 bytes], [data2 length]);
    
    
//    data2 = [NSString AESDecrypt:data2];
//    NSLog(@"%@",data2.description);
//    NSString *ss = [[NSString alloc] initWithData:data2 encoding:NSUTF8StringEncoding];
//    NSLog(@"%@",ss);
    
    
    NSData *data = [NSData dataWithBytes:CommandStructure length:size];
    [self writeData:data tag:tag completion:^(NSData *data) {
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
    [self login:@"111111" withToken:nil completion:^(UInt32 ip, UInt16 port) {
        ;
    } failure:^(NSError *error) {
        ;
    }];
}

-(void)login:(NSString *)pw withToken:(NSData *)token completion:(IMObjectLoginHandler)completion failure:(IMObjectFailureHandler)failure
{
    Byte BB[] = {0xeb, 0xea, 0xa7, 0x96, 0x98, 0x79, 0x1a, 0xa9, 0xaa, 0x17, 0xed, 0x96, 0x44,0xce, 0x5f, 0x0e, 0x06, 0xc0, 0xef, 0xd2, 0x32, 0x92, 0x82, 0xe8, 0xc9, 0x3a, 0xcb, 0x28, 0xdc, 0x15, 0xfe, 0xaa};
    Byte dd[] = {0x1f, 0x00, 0x00, 0x00, 0xf9, 0x71, 0x19, 0x0f};
    
    
    Byte i = 0x37^0xf9;
    Byte j = 0x68^0x71;
    Byte k = 0x99^0x19;
    Byte n = 0x76^0x0f;
    Byte m = 0x13^0x1f;
    
    token = [NSData dataWithBytes:dd length:8];
    NSData *data2 = [pw AESAndXOREncrypt:token];
    NSLog(@"data2 %@",data2);
    
    
    UInt16 size = 14+8+[data2 length];
    char *CommandStructure = malloc(size);
    UInt32 magic = 0xbebaedfe;
    memcpy(CommandStructure, &magic, 4);
    CommandStructure[4] = 0x86;
    CommandStructure[5] = 0x2;
    long tag = ++connectTag;
    memcpy(CommandStructure+6, &tag, 4);
    NSUInteger length = 8+16;//0x10;
    memcpy(CommandStructure+10, &length, 4);
    memcpy(CommandStructure+14, [token bytes], [token length]);
    memcpy(CommandStructure+14 + [token length], [data2 bytes], [data2 length]);
    
    NSData *data = [NSData dataWithBytes:CommandStructure length:size];
    NSLog(@"data %@",data);
    
    [self writeData:data tag:tag completion:^(NSData *data) {
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

-(void)writeData:(NSData *)data tag:(long)tag completion:(IMObjectCompletionHandler)completion failure:(IMObjectFailureHandler)failure{
    [self setudpSocket];
    currentIM = [[IMObject alloc]initWithTag:tag];
    currentIM.completion = completion;
    currentIM.failure = failure;
    [asyncSocket writeData:data withTimeout:-1 tag:tag];
    
}

-(void)listenHeadDataWithIMObject:(IMObject *)im{
    im.lenth = 10;
    [asyncSocket readDataToLength:10 withTimeout:10 tag:im.tag];
}

-(void)listenData:(NSInteger)length WithIMObject:(IMObject *)im{
    im.lenth = length;
    [asyncSocket readDataToLength:length withTimeout:10 tag:im.tag];
    //[asyncSocket readDataToData:[NSData dataWithBytes:"\n" length:1] withTimeout:-1 tag:1];
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
            im.failure([NSError errorWithDomain:@"return code error" code:code userInfo:nil]);
            return;
        }
        if (length == 0) {
            currentIM.finished = YES;
            im.completion(im.data);
        }
        else
            [self listenData:length WithIMObject:im];
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
