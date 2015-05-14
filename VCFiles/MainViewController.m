//
//  MainViewController.m
//  BLE
//
//  Created by JohnsonLee on 12-11-15.
//  Copyright (c) 2012年 ven. All rights reserved.
//

#import "MainViewController.h"
#import "SettingViewController.h"
#import <CoreBluetooth/CoreBluetooth.h>

@interface MainViewController ()<CBCentralManagerDelegate,CBPeripheralDelegate>{
    UIImageView *batteryState;
    UIImageView *connectstate;
    UIButton *lockBtn;
    UILabel *batteryLab;
    NSInteger currentDistance;
    NSTimer *timer;
    BOOL isLock;

    CBCentralManager *manage;
    CBPeripheral *myperipheral;
    NSNumber *securityDistance;
    uint16_t batteryRate;
    
    CBCharacteristic *alarmCharacteristic;
    CBCharacteristic *TXPowerLevelCharacteristic;
    NSMutableArray *batteryCharacteristics;
}
- (void)createMainMenu;
- (void)starScanning;
- (void)stopScanning;

- (void)updateBatteryLevel;
- (void)AlertAction;
@end

@implementation MainViewController

- (id)init
{
    self = [super init];
    if (self) {
        isLock = YES;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(starScan) name:@"starScan" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didEnterBackgroundNotification:) name:@"didEnterBackgroundNotification" object:nil];
    }
    return self;
}

#pragma mark - 消息中心响应

- (void)didEnterBackgroundNotification:(NSNotification*)notification
{
    // Find the fishtank service
    for (CBService *service in [myperipheral services]) {

        for (CBCharacteristic *characteristic in [service characteristics]) {
            
            [myperipheral setNotifyValue:YES forCharacteristic:characteristic];
        }
    }
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self createMainMenu];
    manage = [[CBCentralManager alloc] initWithDelegate:self queue:dispatch_get_main_queue()];
    myperipheral = [[[CBPeripheral alloc] init] retain];
    batteryCharacteristics = [[NSMutableArray alloc] init];
}

- (void)createMainMenu{
    UIImageView *background = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 460.0)];
    background.backgroundColor = [UIColor clearColor];
    background.image = [UIImage imageNamed:@"mainBK.png"];
    [self.view addSubview:background];
    [background release];
    
    //设置
    UIButton *settingBtn = [[UIButton alloc] initWithFrame:CGRectMake(9.0, 8.0, 49.0, 30.0)];
    settingBtn.backgroundColor = [UIColor clearColor];
    [settingBtn setImage:[UIImage imageNamed:@"mainsettingBtn.png"] forState:UIControlStateNormal];
    [settingBtn addTarget:self action:@selector(clickOnSettingBtn) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:settingBtn];
    [settingBtn release];
    
    UIButton *helpBtn = [[UIButton alloc] initWithFrame:CGRectMake(262.0, 8.0, 49.0, 30.0)];
    helpBtn.backgroundColor = [UIColor clearColor];
    [helpBtn setImage:[UIImage imageNamed:@"mainhelpBtn.png"] forState:UIControlStateNormal];
    [helpBtn addTarget:self action:@selector(clickOnHelpBtn) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:helpBtn];
    [helpBtn release];
    
    batteryState = [[UIImageView alloc] initWithFrame:CGRectMake(224.0, 78.0, 39.0, 20.0)];
    batteryState.backgroundColor = [UIColor clearColor];
    batteryState.image = [UIImage imageNamed:@"batter4.png"];
    [self.view addSubview:batteryState];
    [batteryState release];

    
    connectstate = [[UIImageView alloc] initWithFrame:CGRectMake(62.0, 74.0, 35.0, 33.0)];
    connectstate.backgroundColor = [UIColor clearColor];
    connectstate.image = [UIImage imageNamed:@"connectstate.png"];
    [self.view addSubview:connectstate];
    [connectstate release];
    
    //锁
    lockBtn = [[UIButton alloc] initWithFrame:CGRectMake(175.0, 155.0, 35.0, 34.0)];
    lockBtn.backgroundColor = [UIColor clearColor];
    [lockBtn setImage:[UIImage imageNamed:@"lockBtn1.png"] forState:UIControlStateNormal];
    [lockBtn addTarget:self action:@selector(clickOnLockBtn) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:lockBtn];
    [lockBtn release];
    
    //寻找
    UIButton *searchBtn = [[UIButton alloc] initWithFrame:CGRectMake(85.0, 247.0, 155.0, 38.0)];
    searchBtn.backgroundColor = [UIColor clearColor];
    [searchBtn setImage:[UIImage imageNamed:@"searchBtn.png"] forState:UIControlStateNormal];
    [searchBtn addTarget:self action:@selector(clickOnSearchBtn) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:searchBtn];
    [searchBtn release];
    
    //配对
    UIButton *connectBtn = [[UIButton alloc] initWithFrame:CGRectMake(61.0, 415.0, 198.0, 38.0)];
    connectBtn.backgroundColor = [UIColor clearColor];
    [connectBtn setImage:[UIImage imageNamed:@"connectBtn.png"] forState:UIControlStateNormal];
    [connectBtn addTarget:self action:@selector(clickOnConnectBtn) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:connectBtn];
    [connectBtn release];
}

#pragma mark - 消息中心响应
- (void)starScan{
    [self starScanning];
}

- (void)getCoordinates{
    
//    NSLog(@"xxxxxxxx");
    NSDictionary	*options	= [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:NO] forKey:CBCentralManagerScanOptionAllowDuplicatesKey];
    //扫描所有UUID的LE设备
    [manage scanForPeripheralsWithServices:nil options:options];
    [self updateBatteryLevel];
}

#pragma mark - 更新蓝牙电量
- (void)updateBatteryLevel{
    if ((myperipheral && [batteryCharacteristics count]) && myperipheral.isConnected) {
        [myperipheral readValueForCharacteristic:[batteryCharacteristics objectAtIndex:0]];
        [myperipheral readValueForCharacteristic:[batteryCharacteristics objectAtIndex:1]];
        NSLog(@"batteryCharacteristic1.value--%@--batteryCharacteristic12.value--%@",[(CBCharacteristic *)[batteryCharacteristics objectAtIndex:0] value],[(CBCharacteristic *)[batteryCharacteristics objectAtIndex:1] value]);
        
        [myperipheral readRSSI];
         NSLog(@"currentDistance--%i---------%f",currentDistance,[[[NSUserDefaults standardUserDefaults] objectForKey:@"Distance"] floatValue]);
        if (currentDistance < 0 &&(currentDistance < [[[NSUserDefaults standardUserDefaults] objectForKey:@"Distance"] floatValue])) {
            NSLog(@"currentDistance--%i---------%f",currentDistance,[[[NSUserDefaults standardUserDefaults] objectForKey:@"Distance"] floatValue]);
            [self AlertAction];
        }
        NSData * updatedValue = [(CBCharacteristic *)[batteryCharacteristics objectAtIndex:1] value];
        uint32_t *dataPointer = (uint32_t*)[updatedValue bytes];
        if (dataPointer) {
            uint32_t location = dataPointer[0];
            batteryLab.text = [NSString stringWithFormat:@"%i",location];
            NSLog(@"updatedValue---%i",location);
            if (location == 0) {
                batteryState.image = [UIImage imageNamed:@"batter.png"];
            }
            else if(location > 0 && location <= 25){
                batteryState.image = [UIImage imageNamed:@"batter1.png"];
            }
            else if(location > 25 && location <= 50){
                batteryState.image = [UIImage imageNamed:@"batter2.png"];
            }
            else if(location > 50 && location <= 75){
                batteryState.image = [UIImage imageNamed:@"batter3.png"];
            }
            else if(location > 75 && location <= 100){
                batteryState.image = [UIImage imageNamed:@"batter4.png"];
            }
        }
    }
    else if(!myperipheral.isConnected && myperipheral){
        [manage connectPeripheral:myperipheral options:nil];
    }

}

#pragma mark - 响铃
- (void)AlertAction{
    if ((myperipheral && alarmCharacteristic) && myperipheral.isConnected) {
        NSNumber *num = [[NSUserDefaults standardUserDefaults] objectForKey:@"AlarmLevel"];
        if ([num intValue] == 1) {
            //高警告声
            uint16_t val = 2;
            NSData * valData = [NSData dataWithBytes:(void*)&val length:sizeof(val)];
            [myperipheral writeValue:valData forCharacteristic:alarmCharacteristic type:CBCharacteristicWriteWithResponse];
        }
        else if([num intValue] == 2){
            //闪灯
            uint16_t val = 1;
            NSData * valData = [NSData dataWithBytes:(void*)&val length:sizeof(val)];
            NSLog(@"valData ------%@",valData);
            [myperipheral writeValue:valData forCharacteristic:alarmCharacteristic type:CBCharacteristicWriteWithResponse];
        }
        else{
            //高警告声
            uint16_t val = 4;
            NSData * valData = [NSData dataWithBytes:(void*)&val length:sizeof(val)];
            [myperipheral writeValue:valData forCharacteristic:alarmCharacteristic type:CBCharacteristicWriteWithResponse];
            NSLog(@"valData-------%@",valData);
        }
        NSLog(@"myperipheral.RSSI-------123%@",myperipheral.RSSI);
        NSLog(@"myperipheral.isConnected-------123%i",myperipheral.isConnected);
    }
    else if(!myperipheral.isConnected){
        [manage connectPeripheral:myperipheral options:nil];
    }
}

#pragma mark - 搜索设备
- (void)starScanning{
    
    [manage scanForPeripheralsWithServices:nil options:nil];
//    [manage stopScan];
}

- (void)stopScanning{
    [manage stopScan];
}


- (void)clickOnSearchBtn{
    NSLog(@"搜索设备");
    [self starScanning];
}

- (void)clickOnConnectBtn{
    
    if ((myperipheral && TXPowerLevelCharacteristic) && myperipheral.isConnected) {
        [myperipheral readValueForCharacteristic:TXPowerLevelCharacteristic];
        [myperipheral setNotifyValue:YES forCharacteristic:TXPowerLevelCharacteristic];
        NSLog(@"TXPowerLevelCharacteristic.value--%@",[TXPowerLevelCharacteristic value]);
        NSData * updatedValue = [TXPowerLevelCharacteristic value];
        NSLog(@"updatedValue---%@",updatedValue);
        uint32_t *dataPointer = (uint32_t*)[updatedValue bytes];
        if (dataPointer) {
            uint32_t location = dataPointer[0];
            NSLog(@"updatedValue---%i",location);
        }
    }
    else if(!myperipheral.isConnected && myperipheral){
        [manage connectPeripheral:myperipheral options:nil];
    }
}

#pragma mark - CBCentralManagerDelegate协议方法
- (void)centralManagerDidUpdateState:(CBCentralManager *)central{
    if ([central state] == CBCentralManagerStatePoweredOff) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"蓝牙已关闭" message:@"是否打开蓝牙?" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
        [alert release];
    }
}

- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI{
    
    NSLog(@"advertisementData----%@",advertisementData);
    
//    NSLog(@"UUID:%@;Name:%@",peripheral.UUID,peripheral.name);
    
//    NSData *uuid=[CBUUID UUIDWithCFUUID:[peripheral UUID]].data;
//    NSLog(@"xxxx---%@",uuid);
    
//    CFUUIDRef puuid = peripheral.UUID;//CFUUIDCreate( nil );
//    CFStringRef uuidString = CFUUIDCreateString( nil, puuid );
//    NSString * result = (NSString *)CFStringCreateCopy( NULL, uuidString);
//    CFRelease(puuid);
//    CFRelease(uuidString);
//    NSLog(@"resultUUID:%@",result);
    /*
    NSArray *keys = [advertisementData allKeys];
    for (int i = 0; i < [keys count]; ++i) {
        
        id key = [keys objectAtIndex: i];
        NSString *keyName = (NSString *) key;
        NSObject *value = [advertisementData objectForKey: key];
        if ([value isKindOfClass: [NSArray class]]) {

            NSArray *values = (NSArray *) value;
            
            for (int j = 0; j < [values count]; ++j) {
                if ([[values objectAtIndex: j] isKindOfClass: [CBUUID class]]) {
                    CBUUID *uuid = [values objectAtIndex: j];
                    NSData *data = uuid.data;
                    
                    for (int j = 0; j < data.length; ++j){
                        
//                        NSLog(@"str:%2x\n",((UInt8 *) data.bytes)[j]);
                    }
                    
                }
                else {
//                    const char *valueString = [[value description] cStringUsingEncoding: NSUTF8StringEncoding];
//                    printf(" xxx value(%d): %s\n", j, valueString);
                }
            }
            
        } else {
//            const char *valueString = [[value description] cStringUsingEncoding: NSUTF8StringEncoding];
//            printf("   key: %s, value: %s\n", [keyName cStringUsingEncoding: NSUTF8StringEncoding], valueString);
        }
    }
     */
    if (!myperipheral.isConnected) {
        myperipheral = [peripheral retain];
        [manage connectPeripheral:peripheral options:nil];
    }
}



- (void)peripheralDidUpdateRSSI:(CBPeripheral *)peripheral error:(NSError *)error{
    if (!error) {
        NSLog(@"----%@",peripheral.RSSI);
        currentDistance = [peripheral.RSSI integerValue];
    }
}

- (void)centralManager:(CBCentralManager *)central didRetrievePeripherals:(NSArray *)peripherals{
    if ([peripherals count]) {
        for (CBPeripheral *per in peripherals) {
            [central connectPeripheral:per options:[NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES] forKey:CBConnectPeripheralOptionNotifyOnDisconnectionKey]];
        }
    }
}


- (void)centralManager:(CBCentralManager *)central didRetrieveConnectedPeripherals:(NSArray *)peripherals{
    if ([peripherals count]) {
        //自动连接已配对设备
        for (CBPeripheral *peripheral in peripherals) {
            [peripheral retain];
            NSLog(@"peripheral.RSSI-----%@",peripheral.RSSI);
            [peripheral discoverServices:nil];
        }
    }
}


- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral{
    
    NSLog(@"the peripheral is connected!");
    peripheral.delegate = self;
    //搜许所有服务
    [peripheral discoverServices:nil];
    connectstate.hidden = YES;
}

#pragma mark - CBPeripheralDelegate 协议方法
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error{
    
    
    for (CBService *service in [peripheral services]) {
        
//        NSLog(@"service UUID:--%@",[service UUID]);
//        NSLog(@"peripheral UUID:---%@",[peripheral UUID]);
        [myperipheral discoverCharacteristics:nil forService:service];
        
        
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error{
    
//    if ([service.UUID isEqual:[CBUUID UUIDWithString:@"2a19"]]) {
        for (CBCharacteristic *characteristic in  [service characteristics]) {
            NSLog(@"service UUID:%@",service.UUID);
            NSLog(@"characteristic.UUID------%@",characteristic.UUID);
            
            if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:@"2a19"]]) {
                
                alarmCharacteristic = [characteristic retain];
            }
            [myperipheral readValueForCharacteristic:characteristic];
        }
//    }
    //当设备已连接，反复扫描
//    timer = [[NSTimer scheduledTimerWithTimeInterval:3.0 target:self selector:@selector(getCoordinates) userInfo:nil repeats:YES] retain];
//    [timer fire];
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error{
    
//    NSLog(@"characteristic---%@",characteristic);
    NSLog(@"\n  read UUID:%@\n   read Value:%@",characteristic.UUID,characteristic.value);
    
    NSString *values=[[NSString alloc]initWithData:characteristic.value encoding:NSUTF8StringEncoding];
    NSLog(@"get values:%@",values);
    
    if (error)
    {
        NSLog(@"Error Update value for characteristic %@ error: %@", characteristic.UUID, [error localizedDescription]);
        return;
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    [peripheral readValueForCharacteristic:characteristic];
    if (error)
    {
        NSLog(@"Error writing value for characteristic %@ error: %@", characteristic.UUID, [error localizedDescription]);
        return;
    }
}


#pragma mark - 按钮方法实现
- (void)clickOnSettingBtn{
    SettingViewController *ctr = [[SettingViewController alloc] init];
    ctr.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    [self presentModalViewController:ctr animated:YES];
    [ctr release];
}

- (void)clickOnLockBtn{
    
    NSData *data=[@"iosxxx" dataUsingEncoding:NSUTF8StringEncoding];
    [myperipheral writeValue:data forCharacteristic:alarmCharacteristic type:CBCharacteristicWriteWithResponse];
}

@end
