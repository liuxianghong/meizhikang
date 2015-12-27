//
//  BLEConnect.h
//  meizhikang
//
//  Created by 刘向宏 on 15/12/26.
//  Copyright © 2015年 刘向宏. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>



@protocol BLEConnectDelegate<NSObject>

@optional
- (void) peripheralFound;
- (void) setConnect;
- (void) setDisconnect;

@end

@protocol BLEDataDelegate<BLEConnectDelegate>
- (void)didUpdateHealthValue: (NSInteger )value;
- (void)didUpdateHartValue: (NSInteger )value;
@optional

@end

@interface BLEConnect : NSObject
+(instancetype)Instance;
-(void)connect:(CBPeripheral *)peripheral;
-(void)stopScan;
-(void)startScan;
-(void)disconnect:(CBPeripheral *)peripheral;
-(CBPeripheral *)connectedPeripheral;
-(NSArray *)peripherals;
@property (nonatomic, weak) id <BLEDataDelegate> dataDelegate;
@property (nonatomic, weak) id <BLEConnectDelegate> connectDelegate;
@end
