//
//  MailFilterFlipsideViewController.h
//  MailFilter
//
//  Created by Moe Burney on 2012-11-24.
//  Copyright (c) 2012 Dev70. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MailFilterFlipsideViewController;

@protocol MailFilterFlipsideViewControllerDelegate
- (void)flipsideViewControllerDidFinish:(MailFilterFlipsideViewController *)controller;
@end

@interface MailFilterFlipsideViewController : UIViewController
{
    IBOutlet UITextField *serverField;
    IBOutlet UITextField *usernameField;
    IBOutlet UITextField *passwordField;
    IBOutlet UITextField *portField;
}

@property (weak, nonatomic) id <MailFilterFlipsideViewControllerDelegate> delegate;
@property (assign) int accountNum;


- (IBAction)done:(id)sender;

@end
