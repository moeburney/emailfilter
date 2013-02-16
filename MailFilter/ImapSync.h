//
//  ImapSync.h
//  MailFilter
//
//  Created by Moe Burney on 2012-11-27.
//  Copyright (c) 2012 Dev70. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MailCore/MailCore.h>


@class Message;


@interface ImapSync : NSObject
{
    Message *aMessage;
}

@property (assign) int accountNum;
@property (nonatomic, strong) CTCoreAccount *account;


+(ImapSync *) sharedDataManager;
-(id) initWithImapServer;
//-(ImapSync *) initWithImapServer;
-(CTCoreFolder *)createFolder:(NSString *)path;
-(CTCoreFolder *)getInbox;
-(NSUInteger *)getInboxCount;
-(NSSet *)getFolderNames;
-(NSMutableArray *)getMessagesFirstBatch;
-(NSMutableArray *)getMessages:(NSUInteger)start:(NSUInteger)finish;
-(void)filterMessagesAccordingToRules;
-(void)filterMessage:(NSUInteger)uid:(CTCoreFolder *)inbox:(NSString *)folderName;

@end
