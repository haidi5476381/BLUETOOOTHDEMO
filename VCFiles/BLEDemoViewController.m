//
//  BLEDemoViewController.m
//  BLE
//
//  Created by JohnsonLee on 13-4-29.
//  Copyright (c) 2013年 ven. All rights reserved.
//

#import "BLEDemoViewController.h"

#import <CoreBluetooth/CoreBluetooth.h>


@interface BLEDemoViewController ()<CBCentralManagerDelegate,CBPeripheralDelegate>

@property(nonatomic,retain)CBCentralManager *mycentralManager;
@property(nonatomic,retain)CBPeripheral *myperipheral;
@property(nonatomic,retain)CBCharacteristic *mycharacteristic;

@end

@implementation BLEDemoViewController

@synthesize sendMessage,readMessage;
@synthesize mycentralManager,myperipheral,mycharacteristic;

- (void)viewDidLoad
{
    [super viewDidLoad];
}

#pragma mark - 连接、发送、断开
/*-------------------搜索蓝牙设备、连接-------------------*/
- (IBAction)connection:(id)sender{
    
	NSDictionary *options=[NSDictionary dictionaryWithObject:[NSNumber numberWithBool:NO] forKey:CBCentralManagerScanOptionAllowDuplicatesKey];//扫描信息
    
    if (!self.mycentralManager) {
        //实例中央服务
        self.mycentralManager =[[CBCentralManager alloc]initWithDelegate:self queue:dispatch_get_main_queue()];
    }
    
	[self.mycentralManager scanForPeripheralsWithServices:nil options:options];//搜所有服务
}

/*-------------------发送数据-------------------*/
- (IBAction)send:(id)sender{
    
    if (!myperipheral.isConnected) {
        self.readMessage.text=@"sorry! BLE is disconnected";
        return;
    }//排错处理
    
    NSData *data=[self.sendMessage.text dataUsingEncoding:NSUTF8StringEncoding];
    
//    NSLog(@"data===%@",data);
//    NSLog(@"data length:%d",data.length);
//    NSLog(@"sendValues:%@",sendMessage.text);
    
    int dataLength = 0;
    if (data.length%20==0) {
        
        dataLength=data.length/20;//?排错处理60
    }else{
        
        dataLength=data.length/20+1;
    }
    
    for (int i=0; i<dataLength; i++) {
        
        NSData *sendData;
        if (data.length-i*20>=20) {
            
            sendData=[data subdataWithRange:NSMakeRange(i*20, 20)];
//            NSLog(@"----%@", [data subdataWithRange:NSMakeRange(i*20, 20)]);
        }else{
            
            sendData=[data subdataWithRange:NSMakeRange(i*20, data.length-i*20)];
//            NSLog(@"----%@", [data subdataWithRange:NSMakeRange(i*20, data.length-i*20)]);
        }
        
        [self.myperipheral writeValue:sendData forCharacteristic:mycharacteristic type:CBCharacteristicWriteWithResponse];
    }
    
}


/*-------------------断开连接-------------------*/
- (IBAction)disconnection:(id)sender{
    
    if (self.mycentralManager) {
        
        [self.mycentralManager cancelPeripheralConnection:self.myperipheral];
        [self.mycentralManager stopScan];
        
        [self.mycentralManager release];
        [self.mycharacteristic release];
        [self.myperipheral release];
        
        self.mycentralManager =nil;
        self.mycharacteristic =nil;
        self.myperipheral =nil;
    }
    
    
    self.sendMessage.text=@"";
    self.readMessage.text=@"the BLE is disConnected!";
    [self.sendMessage resignFirstResponder];
    [self.readMessage resignFirstResponder];
}


#pragma mark - CBCentralManagerDelegate协议方法

//判断设备蓝牙状态
- (void)centralManagerDidUpdateState:(CBCentralManager *)central{
    if ([central state] == CBCentralManagerStatePoweredOff) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"蓝牙已关闭" message:@"是否打开蓝牙?" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
        [alert release];
    }
}

//发现外围设备
- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI{
    
    NSLog(@"advertisementData----%@",advertisementData);

    if (!self.myperipheral.isConnected) {
        self.myperipheral = [peripheral retain];
        [self.mycentralManager connectPeripheral:self.myperipheral options:nil];
    }
}

//连接外围设备
- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral{
    
    NSLog(@"the peripheral is connected!");
    self.myperipheral.delegate = self;
    //搜索所有服务
    [self.myperipheral discoverServices:nil];
    
}

-(void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error{
    
    NSLog(@"the BLE is disConnected!");
}

#pragma mark - CBPeripheralDelegate 协议方法
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error{
    
    for (CBService *service in [peripheral services]) {
        
        [self.myperipheral discoverCharacteristics:nil forService:service];
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error{
    
    NSLog(@"didDiscoverCharacteristicsForService");
    for (CBCharacteristic *characteristic in  [service characteristics]) {
        if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:@"2a19"]]) {
            
            self.mycharacteristic = [characteristic retain];
            [self.myperipheral readValueForCharacteristic:characteristic];
        }
    }
}
//读取指定特性的数据
- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error{
    
    NSString *values=[[NSString alloc]initWithData:characteristic.value encoding:NSUTF8StringEncoding];
    
//    NSLog(@"characteristic UUID:%@",characteristic.UUID);
    NSLog(@"characteristic Value:%@",values);
//    NSLog(@"characteristic Data:%@",characteristic.value);
    self.readMessage.text=@"";
    self.readMessage.text=[NSString stringWithFormat:@"characteristic UUID:2a19\n Values:%@",values];
    
    if (error)
    {
        self.readMessage.text=[NSString stringWithFormat:@"sorry!reading Error\n characteristic UUID:2a19 \nValues:%@",[error localizedDescription]];
    }
}

//对蓝牙设备写入数据
- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    [self.myperipheral readValueForCharacteristic:characteristic];
}


@end
