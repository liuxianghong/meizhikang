//
//  BLEConnect.m
//  meizhikang
//
//  Created by 刘向宏 on 15/12/26.
//  Copyright © 2015年 刘向宏. All rights reserved.
//

#import "BLEConnect.h"

#define STATUS_SERVICE_UUID    0x6801L
#define STATUS_Stepnumber_UUID 0x9801L
#define STATUS_COMMAN_UUID     0x9802L
#define STATUS_Warnsync_UUID   0x9803L
#define STATUS_Acc_UUID        0x9804L

#define HRV_SERVICE_UUID       0x6802L
#define HRV_HRV_UUID           0x9810L

#define MZKHR_SERVICE_UUID     0x6803L
#define MZKHR_NOTI_UUID        0x9820L

#define HART_SERVICE_UUID      0x180dL
#define HART_NOTI_UUID         0x2a37L


uint64_t reversebytes_uint64t(uint64_t value){
    Byte* ptr = (Byte*)(&value);
    Byte base[8];
    base[0] = 1;
    for(int i = 0; i < 8; ++i){
        base[i] = ptr[7-i];
    }
    uint64_t res = 0;
    memcpy(&res, base, 8);
    return res;
}


@interface BLEConnect()<CBCentralManagerDelegate, CBPeripheralDelegate>
@property (strong, nonatomic) NSMutableArray *peripherals;
@property (strong, nonatomic) CBCentralManager *manager;
@property (strong, nonatomic) CBPeripheral *activePeripheral;
@end

@implementation BLEConnect

@synthesize manager;
@synthesize connectDelegate;
@synthesize dataDelegate;
@synthesize peripherals;
@synthesize activePeripheral;

+(instancetype)Instance
{
    static id _sharedInstance = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        _sharedInstance = [[self alloc] init];
    });
    return _sharedInstance;
}

-(id)init{
    self = [super init];
    peripherals = [[NSMutableArray alloc]init];
    manager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
    return self;
}


-(void)connect:(CBPeripheral *)peripheral
{
//    if (!(peripheral.state == CBPeripheralStateConnected)) {
//        [manager cancelPeripheralConnection:activePeripheral];
//    }
    [manager connectPeripheral:peripheral options:nil];
}

-(void)startScan{
    [self stopScan];
    [peripherals removeAllObjects];
    [manager scanForPeripheralsWithServices:nil options:nil];
    
    CBUUID *uuidSTATUS = [self getUUID:STATUS_SERVICE_UUID];
    NSArray<CBPeripheral *> *peris = [manager retrieveConnectedPeripheralsWithServices:@[uuidSTATUS]];
    
    for (CBPeripheral *p in peris){
        NSLog(@"%@",p);
        if (![peripherals containsObject:p]){
            [peripherals addObject:p];
        }
    }
    if (connectDelegate) {
        [connectDelegate peripheralFound];
    }
    
}

-(void)stopScan
{
    [manager stopScan];
}

-(void)disconnect:(CBPeripheral *)peripheral
{
    [manager cancelPeripheralConnection:peripheral];
}

-(CBPeripheral *)connectedPeripheral{
    return activePeripheral;
}

-(NSArray *)peripherals{
    return peripherals;
}
#pragma mark - CBCentralManager Delegates

- (void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    //TODO: to handle the state updates
    if (central.state == CBCentralManagerStatePoweredOn) {
        
    }
}

- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI
{
    NSLog(@"Now we found device\n");
//    if (!peripherals) {
//        peripherals = [[NSMutableArray alloc] initWithObjects:peripheral, nil];
//        if (connectDelegate) {
//            [connectDelegate peripheralFound];
//        }
//        return;
//    }
    
    if((__bridge CFUUIDRef )peripheral.identifier == NULL) return;
    if(peripheral.name.length < 1) return;
    for (int i = 0; i < [peripherals count]; i++) {
        CBPeripheral *p = [peripherals objectAtIndex:i];
        if((__bridge CFUUIDRef )p.identifier == NULL) continue;
        CFUUIDBytes b1 = CFUUIDGetUUIDBytes((__bridge CFUUIDRef )p.identifier);
        CFUUIDBytes b2 = CFUUIDGetUUIDBytes((__bridge CFUUIDRef )peripheral.identifier);
        if (memcmp(&b1, &b2, 16) == 0) {
            [peripherals replaceObjectAtIndex:i withObject:peripheral];
            NSLog(@"Duplicated peripheral is found...\n");
            return;
        }
    }
    NSLog(@"New peripheral is found...\n");
    [peripherals addObject:peripheral];
    if (connectDelegate) {
        [connectDelegate peripheralFound];
    }
    return;
}

-(void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
    activePeripheral = peripheral;
    activePeripheral.delegate = self;
    
    [activePeripheral discoverServices:nil];
    
    NSLog(@"connected to the active peripheral\n");
}

-(void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    NSLog(@"disconnected to the active peripheral\n");
    if(activePeripheral != nil)
    if (connectDelegate) {
        [connectDelegate setDisconnect];
    }
    activePeripheral = nil;
}

-(void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    NSLog(@"failed to connect to peripheral %@: %@\n", [peripheral name], [error localizedDescription]);
}

#pragma mark - CBPeripheral delegates

-(void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    
    if (error) {
        NSLog(@"%@",error);
        return;
    }
    NSLog(@"didUpdateValueForCharacteristic on : %@ \n %@",[self CBUUIDToString:characteristic.UUID],characteristic.value);
    NSData *data = characteristic.value;
    if ([data length] < 2) {
        return;
    }
    Byte *byte = [data bytes];
    if([self compareCBUUID:characteristic.UUID UUID2:[self getUUID:STATUS_Warnsync_UUID]]) {
        if (byte[0] == 3) {
            UInt8 rote = byte[1];
            UInt32 time = 0;
            memcpy(&time, byte + 2, 4);
            NSDateFormatter *f = [[NSDateFormatter alloc]init];
            f.dateFormat = @"yyyy-MM-dd hh:mm:ss";
            NSDate *date = [NSDate dateWithTimeIntervalSince1970:time];
            NSLog(@" %d %@",rote, [f stringFromDate:date]);
            if (dataDelegate) {
                [dataDelegate didUpdateHartValue:rote];
            }
        }
        else if (byte[0] == 0 && [data length] == 18){
            UInt8 rote = byte[1];
            UInt32 time = 0;
            memcpy(&time, byte + 14, 4);
            NSDate *date = [NSDate dateWithTimeIntervalSince1970:time];
            if (dataDelegate) {
                [dataDelegate didUpdateHealthValue:rote date:date];
            }
        }
    }
    else if([self compareCBUUID:characteristic.UUID UUID2:[self getUUID:HRV_HRV_UUID]]) {
        if (byte[0] == 0 && [data length] == 18){
            UInt8 rote = byte[1];
            UInt32 time = 0;
            memcpy(&time, byte + 14, 4);
            NSDate *date = [NSDate dateWithTimeIntervalSince1970:time];
            if (dataDelegate) {
                [dataDelegate didUpdateHealthValue:rote date:[NSDate date]];
            }
        }
    }
    else if([self compareCBUUID:characteristic.UUID UUID2:[self getUUID:HART_NOTI_UUID]]) {
        if (byte[0] == 0) {
            UInt8 rote = byte[1];
            if (dataDelegate) {
                [dataDelegate didUpdateHartValue:rote];
            }
        }
    }
    
}

- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    
}

- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForDescriptor:(CBDescriptor *)descriptor error:(NSError *)error
{
    
}

- (void)peripheralDidUpdateRSSI:(CBPeripheral *)peripheral error:(NSError *)error
{
    
}


- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error {
    if (!error) {
        NSLog(@"Services of peripheral with UUID : %@ found\r\n",peripheral.identifier);
        [self getAllCharacteristicsFromKeyfob:peripheral];
    }
    else {
        NSLog(@"%@",error);
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error {
    if (!error) {
        NSLog(@"Characteristics of service with UUID : %@ found\r\n",[self CBUUIDToString:service.UUID]);
        
        for(int i = 0; i < service.characteristics.count; i++) { //Show every one
            CBCharacteristic *c = [service.characteristics objectAtIndex:i];
            NSLog(@"Found characteristic %@\r\n",[ self CBUUIDToString:c.UUID]);
            [peripheral setNotifyValue:YES forCharacteristic:c];
        }
        
//        CBUUID *uuidSTATUS = [self getUUID:STATUS_SERVICE_UUID];
//        if([self compareCBUUID:service.UUID UUID2:uuidSTATUS]) {
//            [self notification:STATUS_SERVICE_UUID characteristicUUID:STATUS_Warnsync_UUID p:peripheral on:YES];
//        }
//        
//        uuidSTATUS = [self getUUID:HRV_SERVICE_UUID];
//        if([self compareCBUUID:service.UUID UUID2:uuidSTATUS]) {
//            [self notification:HRV_SERVICE_UUID characteristicUUID:HRV_HRV_UUID p:peripheral on:YES];
//        }
//        
//        uuidSTATUS = [self getUUID:HART_SERVICE_UUID];
//        if([self compareCBUUID:service.UUID UUID2:uuidSTATUS]) {
//            [self notification:HART_SERVICE_UUID characteristicUUID:HART_NOTI_UUID p:peripheral on:YES];
//        }
    }
    else {
        NSLog(@"%@",error);
    }
}


- (void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    if (!error) {
        NSLog(@"Updated notification state for characteristic with UUID %@ on service with  UUID %@ on peripheral with UUID %@\r\n",[self CBUUIDToString:characteristic.UUID],[self CBUUIDToString:characteristic.service.UUID],peripheral.identifier);
       
        CBUUID *uuidSTATUS = [self getUUID:STATUS_Warnsync_UUID];
        if([self compareCBUUID:characteristic.UUID UUID2:uuidSTATUS]) {
            Byte value[6];
            value[0] = 0x10;
            value[1] = 0xFF;
            UInt32 time = (UInt32) [NSDate date].timeIntervalSince1970;
            //memcpy(value+2, &time, 4);
            value[5] = (time & 0xff);
            value[4] = ((time >> 8) & 0xff);
            value[3] = ((time >> 16) & 0xff);
            value[2] = ((time >> 24) & 0xff);
            NSData *data = [NSData dataWithBytes:value length:6];
            [self writeValue:STATUS_SERVICE_UUID characteristicUUID:STATUS_COMMAN_UUID p:activePeripheral data:data];
            if (connectDelegate) {
                [connectDelegate setConnect];
            }
        }
        
    }
    else {
        NSLog(@"Error in setting notification state for characteristic with UUID %@ on service with  UUID %@ on peripheral with UUID %@\r\n",[self CBUUIDToString:characteristic.UUID],[self CBUUIDToString:characteristic.service.UUID],peripheral.identifier);
        NSLog(@"%@",error);
    }
}


#pragma mark -

-(void)getAllCharacteristicsFromKeyfob:(CBPeripheral *)p{
    for (int i=0; i < p.services.count; i++) {
        CBService *s = [p.services objectAtIndex:i];
        NSLog(@"Fetching characteristics for service with UUID : %@\r\n",[self CBUUIDToString:s.UUID]);
        [p discoverCharacteristics:nil forService:s];
//        CBUUID *uuidSTATUS = [self getUUID:STATUS_SERVICE_UUID];
//        [p discoverCharacteristics:nil forService:s];
//        if([self compareCBUUID:s.UUID UUID2:uuidSTATUS]) {
//            [p discoverCharacteristics:nil forService:s];
//        }
//        uuidSTATUS = [self getUUID:HRV_SERVICE_UUID];
//        [p discoverCharacteristics:nil forService:s];
//        if([self compareCBUUID:s.UUID UUID2:uuidSTATUS]) {
//            [p discoverCharacteristics:nil forService:s];
//        }
//        uuidSTATUS = [self getUUID:HART_SERVICE_UUID];
//        [p discoverCharacteristics:nil forService:s];
//        if([self compareCBUUID:s.UUID UUID2:uuidSTATUS]) {
//            [p discoverCharacteristics:nil forService:s];
//        }
    }
}

-(void) notification:(int)serviceUUID characteristicUUID:(int)characteristicUUID p:(CBPeripheral *)p on:(BOOL)on {
    CBUUID *su = [self getUUID:serviceUUID];
    CBUUID *cu = [self getUUID:characteristicUUID];
    CBService *service = [self findServiceFromUUIDEx:su p:p];
    if (!service) {
        return;
    }
    CBCharacteristic *characteristic = [self findCharacteristicFromUUIDEx:cu service:service];
    if (!characteristic) {
        NSLog(@"Could not find characteristic with UUID %@ on service with UUID %@ on peripheral with UUID %@\r\n",[self CBUUIDToString:cu],[self CBUUIDToString:su],p.identifier);
        return;
    }
    [p setNotifyValue:on forCharacteristic:characteristic];
}


-(void)notify: (CBPeripheral *)peripheral on:(BOOL)on
{
    //[self notification:SERVICE_UUID characteristicUUID:CHAR_UUID p:peripheral on:YES];
}


-(void)writeValue:(int)serviceUUID characteristicUUID:(int)characteristicUUID p:(CBPeripheral *)p data:(NSData *)data {
    CBUUID *su = [self getUUID:serviceUUID];
    CBUUID *cu = [self getUUID:characteristicUUID];
    CBService *service = [self findServiceFromUUIDEx:su p:p];
    if (!service) {
        NSLog(@"Could not find service with UUID %@ on peripheral with UUID %@\r\n",[self CBUUIDToString:su],p.identifier);
        return;
    }
    CBCharacteristic *characteristic = [self findCharacteristicFromUUIDEx:cu service:service];
    if (!characteristic) {
        NSLog(@"Could not find characteristic with UUID %@ on service with UUID %@ on peripheral with UUID %@\r\n",[self CBUUIDToString:cu],[self CBUUIDToString:su],p.identifier);
        return;
    }
    
    if(characteristic.properties & CBCharacteristicPropertyWriteWithoutResponse)
    {
        [p writeValue:data forCharacteristic:characteristic type:CBCharacteristicWriteWithoutResponse];
    }else
    {
        [p writeValue:data forCharacteristic:characteristic type:CBCharacteristicWriteWithResponse];
    }
}

-(CBCharacteristic *) findCharacteristicFromUUIDEx:(CBUUID *)UUID service:(CBService*)service {
    for(int i=0; i < service.characteristics.count; i++) {
        CBCharacteristic *c = [service.characteristics objectAtIndex:i];
        if ([self compareCBUUID:c.UUID UUID2:UUID]) return c;
    }
    return nil;
}

-(CBService *) findServiceFromUUIDEx:(CBUUID *)UUID p:(CBPeripheral *)p {
    for(int i = 0; i < p.services.count; i++) {
        CBService *s = [p.services objectAtIndex:i];
        if ([self compareCBUUID:s.UUID UUID2:UUID]) return s;
    }
    return nil;
}

-(CBUUID *)getUUID:(UInt64)head{
    char t[16];
    UInt64 a = (head << 32) | 0x1000;
    a = reversebytes_uint64t(a);
    memcpy(t, &a, 8);
    UInt64 b = 0x800000805f9b34fbL;
    b = reversebytes_uint64t(b);
    memcpy(t+8, &b, 8);
    NSData *data = [[NSData alloc] initWithBytes:t length:16];
    CBUUID *uuid = [CBUUID UUIDWithData:data];
    return uuid;
}

-(BOOL) compareCBUUID:(CBUUID *) UUID1 UUID2:(CBUUID *)UUID2 {
    char b1[16];
    char b2[16];
    [UUID1.data getBytes:b1 length:16];
    [UUID2.data getBytes:b2 length:16];
    if (memcmp(b1, b2, UUID1.data.length) == 0)
        return YES;
    else
        return NO;
}

-(NSString *) CBUUIDToString:(CBUUID *) UUID {
    return [UUID.data description];
}

@end
