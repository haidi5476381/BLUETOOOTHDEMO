//
//  BLEDiscover.h
//  BLE
//
//  Created by JohnsonLee on 12-11-24.
//  Copyright (c) 2012年 ven. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "BLEService.h"

@protocol BLEDiscoveryDelegate <NSObject>
- (void) discoveryDidRefresh;
- (void) discoveryStatePoweredOff;
@end


@interface BLEDiscover : NSObject<CBCentralManagerDelegate, CBPeripheralDelegate>{
    CBCentralManager    *centralManager;
	BOOL				pendingInit;
}
@property (retain, nonatomic) NSMutableArray    *foundPeripherals;
@property (retain, nonatomic) NSMutableArray	*connectedServices;
@property (nonatomic, assign) id<BLEDiscoveryDelegate>      discoveryDelegate;
@property (nonatomic, assign) id<BLEAlarmProtocol>	peripheralDelegate;

+ (id) sharedInstance;

- (void) startScanningForUUIDString:(NSString *)uuidString;
- (void) stopScanning;
- (void) connectPeripheral:(CBPeripheral*)peripheral;
- (void) disconnectPeripheral:(CBPeripheral*)peripheral;
@end
