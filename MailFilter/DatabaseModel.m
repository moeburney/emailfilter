//
//  DatabaseModel.m
//  MailFilter
//
//  Created by Moe Burney on 2013-02-02.
//  Copyright (c) 2013 Dev70. All rights reserved.
//

#import "DatabaseModel.h"
#import <sqlite3.h>

@implementation DatabaseModel

// Initializes the sqlite database
-(DatabaseModel *)initDatabase
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
    }
    
    
    self.filtersDatabase = [[NSBundle mainBundle] pathForResource:@"filters"
                                                             ofType:@"sqlite3"];
    
    if (sqlite3_open([self.filtersDatabase UTF8String], &_db) != SQLITE_OK)
    {
        NSLog(@"Failed to open database!");
    }
    
    return self;
}

// Returns a singleton ImapSync object; can be used as a global object for storing messages
+(DatabaseModel *)sharedDataManager
{
	static dispatch_once_t onceToken = 0;
	static DatabaseModel *dbManager = nil;
	dispatch_once(&onceToken, ^{
		dbManager = [[DatabaseModel alloc] initDatabase];
	});
	return dbManager;
}

-(void)insertFilterRuleInDatabase:(NSString *)senderEmailAddress:(NSString *)subjectTitle:(NSString *)folderName
{
    NSString *query = nil;
    query = [NSString stringWithFormat:@"INSERT INTO filter_rules(sender, subject, folder) Values('%@','%@','%@')", senderEmailAddress, subjectTitle, folderName];
    sqlite3_stmt *compiledStatement;
    
    int result = sqlite3_prepare_v2(self.db, [query UTF8String], -1, &compiledStatement, NULL);
    if (result != SQLITE_OK)
    {
        NSLog(@"Problem with first prepare statement");
        NSLog(@"Prepare-error #%i: %s", result, sqlite3_errmsg(self.db));
    }
    
    sqlite3_step(compiledStatement);
    sqlite3_finalize(compiledStatement);
    sqlite3_close(self.db);
}
-(void)selectFilterRuleFromDatabase
{
    NSString *query = nil;
    query = [NSString stringWithFormat:@"SELECT sender, subject, folder FROM filter_rules WHERE sender != 'q' AND sender !='a'"];
    sqlite3_stmt *compiledStatement1;
    
    int result1 = sqlite3_prepare_v2(self.db, [query UTF8String], -1, &compiledStatement1, NULL);
    if (result1 != SQLITE_OK)
    {
        NSLog(@"Problem with first prepare statement 2nd time");
        NSLog(@"Prepare-error #%i: %s", result1, sqlite3_errmsg(self.db));
    }
    
    if(sqlite3_prepare(self.db, [query UTF8String], -1, &compiledStatement1, NULL) != SQLITE_OK)
    {
        NSLog(@"Problem with second prepare statement 2nd time");
    }
    else
    {
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
    sqlite3_close(self.db);
}


@end
