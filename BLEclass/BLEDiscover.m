//
//  BLEDiscover.m
//  BLE
//
//  Created by JohnsonLee on 12-11-24.
//  Copyright (c) 2012年 ven. All rights reserved.
//

#import "BLEDiscover.h"

@implementation BLEDiscover

@synthesize foundPeripherals;
@synthesize connectedServices;
@synthesize discoveryDelegate;
@synthesize peripheralDelegate;

+ (id) sharedInstance
{
	static BLEDiscover	*this	= nil;
    
	if (!this)
		this = [[BLEDiscover alloc] init];
    
	return this;
}

- (id) init
{
    self = [super init];
    if (self) {
		pendingInit = YES;
		centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:dispatch_get_main_queue()];
        
		foundPeripherals = [[NSMutableArray alloc] init];
		connectedServices = [[NSMutableArray alloc] init];
	}
    return self;
}

- (void) dealloc
{
    assert(NO);
    [super dealloc];
}

#pragma mark -方法实现
- (void) startScanningForUUIDString:(NSString *)uuidString
{
	NSArray			*uuidArray	= [NSArray arrayWithObjects:[CBUUID UUIDWithString:uuidString], nil];
	NSDictionary	*options	= [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:NO] forKey:CBCentralManagerScanOptionAllowDuplicatesKey];
    
	[centralManager scanForPeripheralsWithServices:uuidArray options:options];
}


- (void) stopScanning
{
	[centralManager stopScan];
}

- (void) connectPeripheral:(CBPeripheral*)peripheral
{
	if (![peripheral isConnected]) {
		[centralManager connectPeripheral:peripheral options:nil];
	}
}


- (void) disconnectPeripheral:(CBPeripheral*)peripheral
{
	[centralManager cancelPeripheralConnection:peripheral];
}


#pragma mark - CBCentralManagerDelegate协议方法
- (void) centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
	BLEService	*service	= nil;
	
	/* Create a service instance. */
	service = [[[BLEService alloc] initWithPeripheral:peripheral controller:peripheralDelegate] autorelease];
	[service start];
    
	if (![connectedServices containsObject:service])
		[connectedServices addObject:service];
    
	if ([foundPeripherals containsObject:peripheral])
		[foundPeripherals removeObject:peripheral];
    
    [peripheralDelegate alarmServiceDidChangeStatus:service];
	[discoveryDelegate discoveryDidRefresh];
}


- (void) centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    NSLog(@"Attempted connection to peripheral %@ failed: %@", [peripheral name], [error localizedDescription]);
}


- (void) centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
	BLEService	*service	= nil;
    
	for (service in connectedServices) {
		if ([service peripheral] == peripheral) {
			[connectedServices removeObject:service];
            [peripheralDelegate alarmServiceDidChangeStatus:service];
			break;
		}
	}
    
	[discoveryDelegate discoveryDidRefresh];
}



@end
