//
//  SettingViewController.m
//  BLE
//
//  Created by JohnsonLee on 12-11-15.
//  Copyright (c) 2012年 ven. All rights reserved.
//

#import "SettingViewController.h"
#import <QuartzCore/QuartzCore.h>

@interface SettingViewController (){
    UISlider *slid;
    UISlider *sound;
    UISegmentedControl *segmentedControl ;
}
- (void)createMainMenu;
@end

@implementation SettingViewController

- (id)init
{
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self createMainMenu];
}

- (void)createMainMenu{
    UIImageView *background = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 460.0)];
    background.backgroundColor = [UIColor clearColor];
    background.image = [UIImage imageNamed:@"settingBK.png"];
    [self.view addSubview:background];
    [background release];
    
    segmentedControl = [[UISegmentedControl alloc] initWithFrame:CGRectMake(61.0, 146.0, 208.0, 32.0)];
    segmentedControl.segmentedControlStyle = UISegmentedControlStylePlain;
    [segmentedControl insertSegmentWithTitle:@"无" atIndex:0 animated: NO];
    [segmentedControl insertSegmentWithTitle:@"声响" atIndex:1 animated: NO];
    [segmentedControl insertSegmentWithTitle:@"闪灯" atIndex: 2 animated: NO];
    [segmentedControl addTarget:self action:@selector(controlPressed:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:segmentedControl];
    [segmentedControl release];
    segmentedControl.selectedSegmentIndex = [[[NSUserDefaults standardUserDefaults] objectForKey:@"AlarmLevel"] integerValue];
    
    UIButton *backBtn = [[UIButton alloc] initWithFrame:CGRectMake(9.0, 8.0, 49.0, 30.0)];
    backBtn.backgroundColor = [UIColor clearColor];
    [backBtn setImage:[UIImage imageNamed:@"backBtn.png"] forState:UIControlStateNormal];
    [backBtn addTarget:self action:@selector(clickOnBackBtn) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:backBtn];
    [backBtn release];
    
    UIButton *helpBtn = [[UIButton alloc] initWithFrame:CGRectMake(262.0, 8.0, 49.0, 30.0)];
    helpBtn.backgroundColor = [UIColor clearColor];
    [helpBtn setImage:[UIImage imageNamed:@"mainhelpBtn.png"] forState:UIControlStateNormal];
    [helpBtn addTarget:self action:@selector(clickOnHelpBtn) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:helpBtn];
    [helpBtn release];
    
    //安全距离
    slid = [[UISlider alloc] initWithFrame:CGRectMake(69.0,240.0, 195.0, 40.0)];
    slid.minimumValue=70.0;
    slid.maximumValue=86.0;
    slid.value = 76.0;
    [slid addTarget:self action:@selector(add) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:slid];
    [slid release];
    
//    //音量大小
//    sound = [[UISlider alloc] initWithFrame:CGRectMake(69.0,310.0, 195.0, 40.0)];
//    sound.minimumValue=18;
//    sound.maximumValue=26;
//    [sound addTarget:self action:@selector(sound) forControlEvents:UIControlEventValueChanged];
//    [self.view addSubview:sound];
//    [sound release];
}

- (void)controlPressed:(id)sender {
    int selectedSegment = segmentedControl.selectedSegmentIndex;
    switch (selectedSegment) {
        case 0:
            [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:0] forKey:@"AlarmLevel"];
            break;
        case 1:
            [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:1] forKey:@"AlarmLevel"];
            break;
        case 2:
            [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:2] forKey:@"AlarmLevel"];
            break;
        default:
            break;
    }
    [[NSUserDefaults standardUserDefaults] synchronize];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - UISlide方法响应
-(void)add
{
    [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithInt:-[slid value]] forKey:@"Distance"];
    NSLog(@"Distance-----------=====%f",[[[NSUserDefaults standardUserDefaults] objectForKey:@"Distance"] floatValue]);
}

-(void)sound
{
    [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithInt:[sound value]] forKey:@"textFont"];
}
#pragma mark - 按钮方法实现
- (void)clickOnBackBtn{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"starScan" object:nil];
    [self.presentingViewController dismissModalViewControllerAnimated:YES];
}

- (void)clickOnHelpBtn{
    
}

@end
