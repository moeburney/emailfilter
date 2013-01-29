//
//  CustomMailScrollViewController.m
//  MailFilter
//
//  Created by Moe Burney on 2012-11-26.
//  Copyright (c) 2012 Dev70. All rights reserved.
//

#import "CustomMailScrollViewController.h"
#import "Message.h"

@interface CustomMailScrollViewController ()

@end

@implementation CustomMailScrollViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    //add these child view controllers to display the emails in a UIScrollView
    [self addChildViewController:[self.storyboard instantiateViewControllerWithIdentifier:@"ViewTemp1"]];
    
	[self addChildViewController:[self.storyboard instantiateViewControllerWithIdentifier:@"View1"]];
	[self addChildViewController:[self.storyboard instantiateViewControllerWithIdentifier:@"View2"]];
    [self addChildViewController:[self.storyboard instantiateViewControllerWithIdentifier:@"View3"]];
	[self addChildViewController:[self.storyboard instantiateViewControllerWithIdentifier:@"View4"]];
	[self addChildViewController:[self.storyboard instantiateViewControllerWithIdentifier:@"View5"]];
    
    [self addChildViewController:[self.storyboard instantiateViewControllerWithIdentifier:@"ViewTemp2"]];
    
}

- (IBAction)showFilterPage:(id)sender
{
    Message *msg = [self.messages objectAtIndex:self.pageControl.currentPage - 1];
    NSString *subj = msg.subject;
    NSString *from = msg.senderEmailAddress;
    
    //save current sender email and message subject in NSUserDefaults
    //then it can be accessed by FilterScreenViewController, then erased
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:subj forKey:[NSString stringWithFormat:@"temp_subj"]];
    [defaults setObject:from forKey:[NSString stringWithFormat:@"temp_from"]];
    [NSUserDefaults resetStandardUserDefaults];
    
    //Use segue to load new modal Filter Screen view controller
    [self performSegueWithIdentifier:@"showFilterScreen" sender:Nil];

}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
