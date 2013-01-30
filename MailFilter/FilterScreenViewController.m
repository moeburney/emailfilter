//
//  FilterScreenViewController.m
//  MailFilter
//
//  Created by Moe Burney on 2013-01-28.
//  Copyright (c) 2013 Dev70. All rights reserved.
//

#import "FilterScreenViewController.h"
#import "ImapSync.h"
#import <sqlite3.h>


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
    NSLog(@"%@", temp_from);
    NSLog(@"%@", temp_subj);
    self.sender.text = [@"from " stringByAppendingString:temp_from]; 
    self.subject.text = [@"With the subject " stringByAppendingString:temp_from];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)saveFilterRule:(id)sender
{
    //This method is called when the "save" button is clicked
    
    if(self.senderSwitch.on)
    {
        NSLog(@"sender switch on");
    }
    
    if(self.subjectSwitch.on)
    {
        NSLog(@"subject switch on");
    }
    
    if (self.selectedFolder != nil)
    {
        //create new rule sender and/or subject (if their switches are on)
        //such that all messages that contain subject and/or sender
        //are automatically filtered into selected folder
        
        //TODO: this sqlite code should go in a model file
        sqlite3_stmt *stmt=nil;
        sqlite3 *cruddb;
        
        //insert
        const char *sql = "INSERT INTO filter_rules(sender, subject, folder) VALUES(?,?,?)";
        
        //Open db
        NSString *cruddatabase = [[NSBundle mainBundle] pathForResource:@"banklist"
                                                             ofType:@"sqlite3"];

        sqlite3_open([cruddatabase UTF8String], &cruddb);
        sqlite3_prepare_v2(cruddb, sql, 1, &stmt, NULL);
        sqlite3_bind_text(stmt, 1, [txt UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_int(stmt, 2, integer);
        sqlite3_bind_double(stmt, 3, dbl);
        sqlite3_step(stmt);
        sqlite3_finalize(stmt);
        sqlite3_close(cruddb);
        

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
