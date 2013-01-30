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
       // NSLog(@"sender switch on");
    }
    
    if(self.subjectSwitch.on)
    {
        // NSLog(@"subject switch on");
    }
    
    if (self.selectedFolder != nil)
    {
        //create new rule sender and/or subject (if their switches are on)
        //such that all messages that contain subject and/or sender
        //are automatically filtered into selected folder
        
        //TODO: this sqlite code should go in a model file
        //also needs some validation checks
       // sqlite3_stmt *stmt=nil;
        sqlite3 *cruddb;
        
        //insert
        //const char *sql = "INSERT INTO filter_rules(sender, subject, folder) VALUES(?,?,?)";
        NSString *sql = nil;
        sql = [NSString stringWithFormat:@"INSERT INTO filter_rules(sender, subject, folder) Values('%@','%@', '%@')", @"a", @"b", @"c"];
        
        sqlite3_stmt *compiledStatement;
        
        //Open db
        NSString *cruddatabase = [[NSBundle mainBundle] pathForResource:@"filters"
                                                             ofType:@"sqlite3"];
        
        if (sqlite3_open([cruddatabase UTF8String], &cruddb) != SQLITE_OK)
        {
            NSLog(@"Failed to open database!");
        }

        int result = sqlite3_prepare_v2(cruddb, [sql UTF8String], -1, &compiledStatement, NULL);
        if (result != SQLITE_OK)
        {
            NSLog(@"Problem with first prepare statement");
            NSLog(@"Prepare-error #%i: %s", result, sqlite3_errmsg(cruddb));

        }
        /*
        sqlite3_bind_text(stmt, 1, [@"l" UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_text(stmt, 2, [@"a" UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_text(stmt, 3, [@"o" UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_step(stmt);
        sqlite3_finalize(stmt);
        */
        sqlite3_finalize(compiledStatement);
        

        //NSLog(@"insertion complete");
        
        NSString *sql1 = nil;
        sql1 = [NSString stringWithFormat:@"SELECT id, sender, subject, folder FROM filter_rules"];
        sqlite3_stmt *compiledStatement1;
        
        if(sqlite3_prepare(cruddb, [sql1 UTF8String], -1, &compiledStatement1, NULL) != SQLITE_OK)
        {
            NSLog(@"Problem with second prepare statement");
        }
        
        
        while (sqlite3_step(compiledStatement1)==SQLITE_ROW) {
            NSString *sndr = [NSString stringWithUTF8String:(char *) sqlite3_column_text(compiledStatement1,1)];
            NSLog(@"%@", sndr);
        }
        
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
