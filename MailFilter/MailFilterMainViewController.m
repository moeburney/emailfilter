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
#import "ImapSync.h"

@interface MailFilterMainViewController ()

@end

@implementation MailFilterMainViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.

    
    //TODO: if settings are filled out, fetch inbox message count
    //then display dialog if user would like to review mails or not
    
    //connect to the server
    ImapSync *dataManager = [ImapSync sharedDataManager];
    
    //filter messages
    NSUInteger *inboxCount = [dataManager getInboxCount];

    //dialog w/ inboxCount and choices
    NSString *inboxCountString = [NSString stringWithFormat:@"You have %ld", (long)inboxCount];
    inboxCountString = [inboxCountString stringByAppendingString:@" emails in your inbox."];

    UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"MailFilter"
                                                      message:inboxCountString
                                                     delegate:self
                                            cancelButtonTitle:@"Review Emails"
                                            otherButtonTitles:@"No Thanks", nil];
    [message show];
    
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
 //   if ([[segue identifier] isEqualToString:@"showAlternate"]) {
   //     [[segue destinationViewController] setDelegate:self];
    //}
    
    //if ([[segue identifier] isEqualToString:@"showMails"]) {
     //   [[segue destinationViewController] setDelegate:self];
    //}
}

- (IBAction)showMessage:(id)sender {
    //TODO: Here we should present the # of emails to be filtered and ask the user if he wants to
    //run the filtering process
    //THEN ask him if he would like to view the remaining n emails (where n is number of emails after filter process)
    /*
    UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"MailFilter"
                                                      message:@"Your inbox will be filtered and then all remaining emails can be reviewed. Would you like to continue?"
                                                     delegate:self
                                            cancelButtonTitle:@"Cancel"
                                            otherButtonTitles:@"OK", nil];
    [message show];
     */
}


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    
    NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
    if([title isEqualToString:@"Review Emails"])
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
