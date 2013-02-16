//
//  FilterScreenViewController.m
//  MailFilter
//
//  Created by Moe Burney on 2013-01-28.
//  Copyright (c) 2013 Dev70. All rights reserved.
//

#import "FilterScreenViewController.h"
#import "ImapSync.h"
#import "DatabaseModel.h"


@interface FilterScreenViewController ()

@end

@implementation FilterScreenViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];                      
	// Do any additional setup after loading the view.
    ImapSync *dataManager = [ImapSync sharedDataManager];
    self.folders = [[dataManager getFolderNames] allObjects];
    
    //get subject and email to be filtered
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSString *temp_subj = [prefs stringForKey:@"temp_subj"];
    NSString *temp_from = [prefs stringForKey:@"temp_from"];
   // NSLog(@"%@", temp_from);
   // NSLog(@"%@", temp_subj);
    self.sender.text = [@"from " stringByAppendingString:temp_from];
    self.subject.text = [@"With the subject " stringByAppendingString:temp_subj];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)saveFilterRule:(id)sender
{
    //This method is called when the "save" button is clicked
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSString *sndr = nil;
    NSString *subj = nil;
    NSString *fldr = nil;
    
    if(self.senderSwitch.on)
    {
        sndr = [prefs stringForKey:@"temp_from"];

    }
    
    if(self.subjectSwitch.on)
    {
        subj = [prefs stringForKey:@"temp_subj"];
    }
    
    
    //create new rule sender and/or subject (if their switches are on)
    //such that all messages that contain subject and/or sender
    //are automatically filtered into selected folder
    if (self.selectedFolder != nil)
    {
        fldr = self.selectedFolder;

        //get the dbManager singleton which comes from DatabaseModel
        DatabaseModel *dbManager = [DatabaseModel sharedDataManager];
        
        //ONLY FOR TESTING: clear the db
        //[dbManager clearDatabase];
        
        //then call the function to insert the records.
        //this saves the filter rules
        [dbManager insertFilterRuleInDatabase:sndr :subj :fldr];
        
        [dbManager selectFilterRuleFromDatabase];
       
    }

}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [self.folders count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //TODO: get the data from a model class delegate, perhaps ImapSync
    //the data should be all the folder names of the user's account
    //then figure out how to save a filter rule
    
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView
                             dequeueReusableCellWithIdentifier:CellIdentifier];
	
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
	
    NSString *currentFolder = [self.folders objectAtIndex:indexPath.row];
	cell.textLabel.text = currentFolder;
    

    return cell;
    
}

- (IBAction)dismissFilterPage:(id)sender
{
    [[self presentingViewController] dismissViewControllerAnimated:YES completion:nil];
}

/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */


/*
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    

}
*/



/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
 {
 }
 */

/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *selectedCell = [tableView cellForRowAtIndexPath:indexPath];
    if (selectedCell != nil)
    {
        self.selectedFolder = selectedCell.textLabel.text;
    }
    
}


@end
