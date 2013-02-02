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
       // NSLog(@"sender switch on");
        sndr = [prefs stringForKey:@"temp_from"];

    }
    
    if(self.subjectSwitch.on)
    {
        subj = [prefs stringForKey:@"temp_subj"];
    }
    
    if (self.selectedFolder != nil)
    {
        fldr = self.selectedFolder;
        //create new rule sender and/or subject (if their switches are on)
        //such that all messages that contain subject and/or sender
        //are automatically filtered into selected folder
        
        //TODO: this sqlite code should go in a model file
        //also needs some validation checks

        sqlite3 *cruddb;
        
        //insert
        //const char *sql = "INSERT INTO filter_rules(sender, subject, folder) VALUES(?,?,?)";
        NSString *sql = nil;
        //sql = [NSString stringWithFormat:@"DELETE FROM filter_rules WHERE 1"];
        sql = [NSString stringWithFormat:@"INSERT INTO filter_rules(sender, subject, folder) Values('%@','%@','%@')", sndr, subj, fldr];
        sqlite3_stmt *compiledStatement;
        
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSString *path = [documentsDirectory stringByAppendingPathComponent:@"filters.sqlite3"];
        
        NSFileManager *fileManager = [NSFileManager defaultManager];
        
        if (![fileManager fileExistsAtPath: path])
        {
            NSString *bundle =  [[NSBundle mainBundle] pathForResource:@"filters" ofType:@"sqlite3"];
            [fileManager copyItemAtPath:bundle toPath:path error:nil];
        }

        
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
        sqlite3_step(compiledStatement);
        sqlite3_finalize(compiledStatement);
        sqlite3_close(cruddb);


        sqlite3 *cruddb1;

        NSString *sql1 = nil;
        sql1 = [NSString stringWithFormat:@"SELECT sender, subject, folder FROM filter_rules WHERE sender != 'q' AND sender !='a'"];
        sqlite3_stmt *compiledStatement1;
        
        //Open db
        NSString *cruddatabase1 = [[NSBundle mainBundle] pathForResource:@"filters"
                                                                 ofType:@"sqlite3"];
        
        if (sqlite3_open([cruddatabase1 UTF8String], &cruddb1) != SQLITE_OK)
        {
            NSLog(@"Failed to open database 2nd time!");
        }

        
        int result1 = sqlite3_prepare_v2(cruddb1, [sql UTF8String], -1, &compiledStatement1, NULL);
        if (result1 != SQLITE_OK)
        {
            NSLog(@"Problem with first prepare statement 2nd time");
            NSLog(@"Prepare-error #%i: %s", result1, sqlite3_errmsg(cruddb));
            
        }

        
        if(sqlite3_prepare(cruddb1, [sql1 UTF8String], -1, &compiledStatement1, NULL) != SQLITE_OK)
        {
            NSLog(@"Problem with second prepare statement 2nd time");
        }
        else
        {
            //int stepResult = sqlite3_step(compiledStatement1);
           // NSLog(@"step result integer is ");
           // NSLog(@"%i", stepResult);
            //if(stepResult == SQLITE_ROW)
            
            if(sqlite3_step(compiledStatement1))
            {
                char *sender = (char *)sqlite3_column_text(compiledStatement1, 0);
                char *subject = (char *)sqlite3_column_text(compiledStatement1, 1);
                char *folder = (char *)sqlite3_column_text(compiledStatement1, 2);

                NSString *sndr1;
                NSString *fldr1;
                NSString *subj1;
                
                if (sender == nil) {
                    sndr1 = nil;
                } else {
                    sndr1 = [NSString stringWithUTF8String: sender];
                }
            
                
                if (subject == nil) {
                    subj1 = nil;
                } else {
                    subj1 = [NSString stringWithUTF8String: subject];
                }
                
                if (folder == nil) {
                    fldr1 = nil;
                } else {
                    fldr1 = [NSString stringWithUTF8String: folder];
                }

                
                NSLog(@"%@", sndr1);
                NSLog(@"%@", fldr1);
                NSLog(@"%@", subj1);

            }
             
        }
        
  

        sqlite3_finalize(compiledStatement1);

        sqlite3_close(cruddb1);

      
        
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
