//
//  CustomMailScrollViewController.m
//  MailFilter
//
//  Created by Moe Burney on 2012-11-26.
//  Copyright (c) 2012 Dev70. All rights reserved.
//

#import "CustomMailScrollViewController.h"

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
/*
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"showFilterPage"]) {
        [[segue destinationViewController] setDelegate:self];
    }
    
}
 */
/*
- (IBAction)showFilterPage:(id)sender;
{
   // [self performSegueWithIdentifier:@"showFilterPage" sender:Nil];
    NSLog(@"fix delegate here");
    
}
 */

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
