//
//  DatabaseModel.h
//  MailFilter
//
//  Created by Moe Burney on 2013-02-02.
//  Copyright (c) 2013 Dev70. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>

@interface DatabaseModel : NSObject

@property (nonatomic) sqlite3 *db;
@property (nonatomic,retain) NSString *filtersDatabase;
@property (nonatomic,retain) NSArray *paths;
@property (nonatomic,retain) NSString *documentsDirectory;
@property (nonatomic,retain) NSString *path;
@property (nonatomic,retain) NSFileManager *fileManager;


+(DatabaseModel *)sharedDataManager;
-(void)insertFilterRuleInDatabase:(NSString *)senderEmailAddress:(NSString *)subjectTitle:(NSString *)folderName;
-(void)selectFilterRuleFromDatabase;
-(NSDictionary *)getRules;


@end
