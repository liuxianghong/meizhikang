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

//IM系统地址182.150.44.21，端口9527
//数据上传系统鉴权地址182.150.44.21，端口9529
//数据上传系统上传服务器地址由鉴权协议返回，目前应该是182.150.44.21，端口9530

#define IMIP @"182.150.44.21"
//@"192.168.16.102"//
#define IMPORT 9527

@implementation IMConnect
{
    GCDAsyncUdpSocket* udpSocket;
    
    GCDAsyncSocket *asyncSocket;
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
    udpSocket = [[GCDAsyncUdpSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
    [self setudpSocket];
    return self;
}

- (void)setudpSocket
{
    NSLog(@"setudpSocket");
    NSError *error = nil;
    
    if (![udpSocket bindToPort:15000 error:&error])
    {
        NSLog(@"Error binding: %@", error);
        return;
    }
    if (![udpSocket beginReceiving:&error])
    {
        NSLog(@"Error receiving: %@", error);
        return;
    }
    
    NSLog(@"%@",@"UDP Ready");
    
    [udpSocket enableBroadcast:TRUE error:nil];
}


#pragma mark - udpSocket
- (void)udpSocket:(GCDAsyncUdpSocket *)sock didSendDataWithTag:(long)tag
{
    // You could add checks here
    NSLog(@"didSendDataWithTag %ld",tag);
}

/**
 * Called when the socket is closed.
 **/
- (void)udpSocketDidClose:(GCDAsyncUdpSocket *)sock withError:(NSError *)error
{
    NSLog(@"udpSocketDidClose %@",error.localizedDescription);
    //[self resetSocket];
}

- (void)udpSocket:(GCDAsyncUdpSocket *)sock didNotSendDataWithTag:(long)tag dueToError:(NSError *)error
{
    NSLog(@"didNotSendDataWithTag %ld%@",tag,error);
    // You could add checks here
}

- (void)udpSocket:(GCDAsyncUdpSocket *)sock didReceiveData:(NSData *)data
      fromAddress:(NSData *)address
withFilterContext:(id)filterContext
{
    NSLog(@"didReceiveData :%@",data);
}


-(void)test
{
    NSString *str = @"11111111";
    NSData *data2 = [str AESEncrypt];
    NSLog(@"%@",data2.description);
    
    UInt16 size = 14+[data2 length];
    char *CommandStructure = malloc(size);
    UInt32 magic = 0xbebaedfe;
    memcpy(CommandStructure, &magic, 4);
    CommandStructure[4] = 0x86;
    CommandStructure[5] = 0x1;
    UInt32 cmd = 0x56693cc9;//403c6956;
    memcpy(CommandStructure+6, &cmd, 4);
    UInt32 length = 0x10;
    memcpy(CommandStructure+10, &length, 4);
    memcpy(CommandStructure+14, [data2 bytes], [data2 length]);
    
    
//    data2 = [NSString AESDecrypt:data2];
//    NSLog(@"%@",data2.description);
//    NSString *ss = [[NSString alloc] initWithData:data2 encoding:NSUTF8StringEncoding];
//    NSLog(@"%@",ss);
    
    
    
    NSData *data = [NSData dataWithBytes:CommandStructure length:size];
    [udpSocket sendData:data toHost:IMIP port:IMPORT withTimeout:-1 tag:0];
    
    dispatch_queue_t mainQueue = dispatch_get_main_queue();
    
    asyncSocket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:mainQueue];
    NSString *host = IMIP;
    uint16_t port = IMPORT;
    NSError *error = nil;
    if (![asyncSocket connectToHost:host onPort:port error:&error])
    {
        NSLog(@"无法建立连接");
    }
    else
    {
        NSLog(@"成功建立连接");
        NSLog(@"%@",data.description);
        
        [asyncSocket writeData:data withTimeout:-1 tag:0];
        [asyncSocket writeData:[GCDAsyncSocket CRLFData] withTimeout:-1 tag:0];
        [self listenData];
    }
    
    free(CommandStructure);
}

//发起一个读取的请求，当收到数据时后面的didReadData才能被回调
-(void)listenData {
    [asyncSocket readDataToData:[GCDAsyncSocket LFData] withTimeout:-1 tag:1];
}

- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(UInt16)port
{
    NSLog(@"didConnectToHost");
    [self listenData];
}

- (void)socketDidSecure:(GCDAsyncSocket *)sock
{
    NSLog(@"socketDidSecure");
}

- (void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag
{
    NSLog(@"socket:%p didWriteDataWithTag:%ld", sock, tag);
    [self listenData];
}

- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
    NSLog(@"socket:%p didReadData:withTag:%ld %@", sock, tag ,data);
    
    NSString *httpResponse = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    NSLog(@"HTTP Response:\n%@", httpResponse);
    [self listenData];
    
}

- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err
{
    NSLog(@"socket: DidDisconnect:%p withError: %@", sock, err);
}
@end
