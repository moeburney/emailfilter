//
//  MailFilterFlipsideViewController.m
//  MailFilter
//
//  Created by Moe Burney on 2012-11-24.
//  Copyright (c) 2012 Dev70. All rights reserved.
//

#import "MailFilterFlipsideViewController.h"
#import "Settings.h"


@interface MailFilterFlipsideViewController ()

@end

@implementation MailFilterFlipsideViewController

@synthesize accountNum;

- (void)viewDidLoad
{
    self.accountNum = 1;
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    usernameField.text = [Settings username:self.accountNum];
    passwordField.text = [Settings password:self.accountNum];
    portField.text = [NSString stringWithFormat:@"%d",[Settings serverPort:self.accountNum]];
    serverField.text = [Settings server:self.accountNum];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Actions

- (IBAction)done:(id)sender
{
    [self.delegate flipsideViewControllerDidFinish:self];
    
    NSLog(@"%d", self.accountNum);
    NSString *username = [usernameField text];
    NSString *password = [passwordField text];
    int port = [[portField text] integerValue];
    NSString *server = [serverField text];
    [Settings setServer:server accountNum:self.accountNum];
    [Settings setPassword:password accountNum:self.accountNum];
    [Settings setServerPort:port accountNum:self.accountNum];
    [Settings setUsername:username accountNum:self.accountNum];
}

@end
