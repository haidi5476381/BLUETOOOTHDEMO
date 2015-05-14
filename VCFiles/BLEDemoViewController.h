//
//  BLEDemoViewController.h
//  BLE
//
//  Created by JohnsonLee on 13-4-29.
//  Copyright (c) 2013年 ven. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BLEDemoViewController : UIViewController{
    
    
}


@property(nonatomic,retain) IBOutlet UITextView *readMessage;
@property(nonatomic,retain) IBOutlet UITextField *sendMessage;

- (IBAction)connection:(id)sender;

- (IBAction)send:(id)sender;

- (IBAction)disconnection:(id)sender;

@end
