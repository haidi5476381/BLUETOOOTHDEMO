//
//  BLEService.h
//  BLE
//
//  Created by JohnsonLee on 12-11-24.
//  Copyright (c) 2012年 ven. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

@class BLEService;

typedef enum {
    kAlarmHigh  = 0,
    kAlarmLow   = 1,
} AlarmType;


@protocol BLEAlarmProtocol<NSObject>
- (void) alarmService:(BLEService*)service didSoundAlarmOfType:(AlarmType)alarm;
- (void) alarmServiceDidStopAlarm:(BLEService*)service;
- (void) alarmServiceDidChangeTemperature:(BLEService*)service;
- (void) alarmServiceDidChangeTemperatureBounds:(BLEService*)service;
- (void) alarmServiceDidChangeStatus:(BLEService*)service;
- (void) alarmServiceDidReset;

@end



@interface BLEService : NSObject<CBPeripheralDelegate>{
}
@property (readonly) CGFloat temperature;
@property (readonly) CGFloat minimumTemperature;
@property (readonly) CGFloat maximumTemperature;
@property (readonly) CBPeripheral *peripheral;


- (id) initWithPeripheral:(CBPeripheral *)peripheral controller:(id<BLEAlarmProtocol>)controller;
- (void) reset;
- (void) start;

- (void) writeLowAlarmTemperature:(int)low;
- (void) writeHighAlarmTemperature:(int)high;
- (void)enteredBackground;
- (void)enteredForeground;


@end
