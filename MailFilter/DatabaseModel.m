//
//  DatabaseModel.m
//  MailFilter
//
//  Created by Moe Burney on 2013-02-02.
//  Copyright (c) 2013 Dev70. All rights reserved.
//

#import "DatabaseModel.h"
#import <sqlite3.h>
#import "Message.h"

@implementation DatabaseModel

-(id)init {
    return [self initWithDatabaseConnection];
}

// Initializes the sqlite database
-(id)initWithDatabaseConnection
{
    self = [super init];

    self.paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    self.documentsDirectory = [self.paths objectAtIndex:0];
    self.path = [self.documentsDirectory stringByAppendingPathComponent:@"filters.sqlite3"];
    self.fileManager = [NSFileManager defaultManager];

    
    if (![self.fileManager fileExistsAtPath: self.path])
    {
        NSString *bundle =  [[NSBundle mainBundle] pathForResource:@"filters" ofType:@"sqlite3"];
        [self.fileManager copyItemAtPath:bundle toPath:self.path error:nil];
        NSLog(@"copied db to documents dir");
    }
 
    //self.filtersDatabase = [[NSBundle mainBundle] pathForResource:@"filters"
                                                             //ofType:@"sqlite3"];
    self.filtersDatabase = self.path;
    //NSLog(@"got filters from db dir");

    
    return self;
}

// Returns a singleton ImapSync object; can be used as a global object for storing messages
+(DatabaseModel *)sharedDataManager
{
	static dispatch_once_t onceToken = 0;
	static DatabaseModel *dbManager = nil;
	dispatch_once(&onceToken, ^{
		dbManager = [[DatabaseModel alloc] initWithDatabaseConnection];
	});
	return dbManager;
}

-(void)openDatabase
{
    sqlite3 *db;
    if (sqlite3_open([self.filtersDatabase UTF8String], &db) != SQLITE_OK)
    {
        NSLog(@"Failed to open database!");
    }
    self.db = db;
}

-(void)closeDatabase
{
    if (sqlite3_close(self.db) != SQLITE_OK)
    {
        NSLog(@"Failed to close database");
    }
}

-(void)insertFilterRuleInDatabase:(NSString *)senderEmailAddress:(NSString *)subjectTitle:(NSString *)folderName
{
    //TODO: Insert account (email address) as a column as well
    
    [self openDatabase];
    NSString *query = nil;
    query = [NSString stringWithFormat:@"INSERT INTO filter_rules(sender, subject, folder) Values('%@','%@','%@')", senderEmailAddress, subjectTitle, folderName];
    sqlite3_stmt *compiledStatement;
    
    int result = sqlite3_prepare_v2(self.db, [query UTF8String], -1, &compiledStatement, NULL);
    if (result != SQLITE_OK)
    {
        NSLog(@"Problem with first prepare statement");
        NSLog(@"Prepare-error #%i: %s", result, sqlite3_errmsg(self.db));
    }
    
    if (sqlite3_step(compiledStatement))
    {
        NSLog(@"%@", query);
    }
    sqlite3_finalize(compiledStatement);
    [self closeDatabase];
}

-(void)selectFilterRuleFromDatabase
{
    [self openDatabase];
    NSString *query = nil;
    query = [NSString stringWithFormat:@"SELECT sender, subject, folder FROM filter_rules WHERE sender != 'q' AND sender !='a'"];
    sqlite3_stmt *compiledStatement1;
    
    int result = sqlite3_prepare_v2(self.db, [query UTF8String], -1, &compiledStatement1, NULL);
    if (result != SQLITE_OK)
    {
        NSLog(@"Problem with first prepare statement for selectFilterRuleFromDatabase");
        NSLog(@"Prepare-error #%i: %s", result, sqlite3_errmsg(self.db));
    }
    else
    {
        while(sqlite3_step(compiledStatement1) == SQLITE_ROW)
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
    [self closeDatabase];
}

-(void)clearDatabase
{
    NSLog(@"clearDatabase method");

    [self openDatabase];
    NSString *query = nil;
    query = [NSString stringWithFormat:@"delete from filter_rules"];
    sqlite3_stmt *compiledStatement;
    
    int result = sqlite3_prepare_v2(self.db, [query UTF8String], -1, &compiledStatement, NULL);
    if (result != SQLITE_OK)
    {
        NSLog(@"Problem with first prepare statement");
        NSLog(@"Prepare-error #%i: %s", result, sqlite3_errmsg(self.db));
    }
    
    if(sqlite3_step(compiledStatement) == SQLITE_DONE) {
        // Read the data from the result row
        NSLog(@"deleted table");
    }
    sqlite3_finalize(compiledStatement);
    [self closeDatabase];
}

-(NSMutableArray *)getRules
{
    NSMutableArray *rules = [[NSMutableArray alloc] initWithObjects: nil];
    NSDictionary *rulesDict;
    [self openDatabase];
    NSString *query = nil;
    query = [NSString stringWithFormat:@"SELECT sender, subject, folder FROM filter_rules"];
 
    sqlite3_stmt *compiledStatement2;
    
    int result = sqlite3_prepare_v2(self.db, [query UTF8String], -1, &compiledStatement2, NULL);
    if (result != SQLITE_OK)
    {
        NSLog(@"Problem with first prepare statement for selectFilterRuleFromDatabase");
        NSLog(@"Prepare-error #%i: %s", result, sqlite3_errmsg(self.db));
    }
    else
    {
        while(sqlite3_step(compiledStatement2) == SQLITE_ROW)
        {
            //NSLog(@"looping through row in getRules");
            char *sender = (char *)sqlite3_column_text(compiledStatement2, 0);
            char *subject = (char *)sqlite3_column_text(compiledStatement2, 1);
            char *folder = (char *)sqlite3_column_text(compiledStatement2, 2);
            
            id sndr1;
            id fldr1;
            id subj1;
                       
            if (sender == nil) {
                sndr1 = [NSNull null];
            } else {
                sndr1 = [NSString stringWithUTF8String: sender];
            }
            
            if (subject == nil) {
                subj1 = [NSNull null];
            } else {
                //NSLog(@"subj returned not nil");
                subj1 = [NSString stringWithUTF8String: subject];
                //NSLog(@"%@", subj1);
            }
            
            if (folder == nil) {
                fldr1 = [NSNull null];
            } else {
                fldr1 = [NSString stringWithUTF8String: folder];
                //NSLog(@"%@", fldr1);

            }
        
            rulesDict = [NSDictionary dictionaryWithObjectsAndKeys:
                                       sndr1, @"sndr",
                                       subj1, @"subj",
                                       fldr1, @"fldr",
                                       nil];
            [rules addObject:rulesDict];


        }
        
    }
    
    sqlite3_finalize(compiledStatement2);
    [self closeDatabase];
    

    return rules;
}
@end
