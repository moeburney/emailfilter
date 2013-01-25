//
//  MailFilterMainViewController.m
//  MailFilter
//
//  Created by Moe Burney on 2012-11-24.
//  Copyright (c) 2012 Dev70. All rights reserved.
//

#import "MailFilterMainViewController.h"
#import "MailScrollViewController.h"
#import "CustomMailScrollViewController.h"


@interface MailFilterMainViewController ()

@end

@implementation MailFilterMainViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Flipside View

- (void)flipsideViewControllerDidFinish:(MailFilterFlipsideViewController *)controller
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"showAlternate"]) {
        [[segue destinationViewController] setDelegate:self];
    }
    
    //if ([[segue identifier] isEqualToString:@"showMails"]) {
     //   [[segue destinationViewController] setDelegate:self];
    //}
}

- (IBAction)showMessage:(id)sender {
    UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"MailFilter"
                                                      message:@"You have new emails. Would you like to review them now?"
                                                     delegate:self
                                            cancelButtonTitle:@"Cancel"
                                            otherButtonTitles:@"OK", nil];
    [message show];
}


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
    if([title isEqualToString:@"OK"])
    {
         [self performSegueWithIdentifier:@"showMails" sender:Nil];
        
        // Create the root view controller for the navigation controller
        // The new view controller configures a Cancel and Done button for the
        // navigation bar.
        
        //CustomMailScrollViewController *addController = [[CustomMailScrollViewController alloc]
                                                  //init];

        // Configure the RecipeAddViewController. In this case, it reports any
        // changes to a custom delegate object.
        //addController.delegate = self;
        
        // Create the navigation controller and present it.
       // UINavigationController *navigationController = [[UINavigationController alloc]
        //                                                initWithRootViewController:addController];
       
        //[self presentViewController:addController animated:YES completion: nil];
    }

}

@end
