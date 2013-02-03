//
//  ImapSync.m
//  MailFilter
//
//  Created by Moe Burney on 2012-11-27.
//  Copyright (c) 2012 Dev70. All rights reserved.
//

#import "ImapSync.h"
#import "Settings.h"
#import "Message.h"
#import <MailCore/MailCore.h>

@implementation ImapSync
@synthesize account, accountNum;


- (ImapSync *)initWithImapServer
{
    NSLog(@"trying to connect...");

    self = [super init];
    self.accountNum = 1;
    self.account = [[CTCoreAccount alloc] init];
        
    BOOL success = [self.account connectToServer:[Settings server:self.accountNum]
                                            port:[Settings serverPort:self.accountNum]
                                  connectionType:CONNECTION_TYPE_TLS
                                        authType:IMAP_AUTH_TYPE_PLAIN
                                           login:[Settings username:self.accountNum]
                                        password:[Settings password:self.accountNum]];
    
    //code to connect to my local server, delete this before releasing production version
    /*
    BOOL success = [self.account connectToServer:@"localhost"
                                            port:10143
                                  connectionType:CONNECTION_TYPE_PLAIN
                                        authType:IMAP_AUTH_TYPE_PLAIN
                                           login:@"moeburney"
                                        password:@"password"];
    */

    if (!success)
    {
        NSLog(@"%@",[Settings username:self.accountNum]);
        NSLog(@"%@",[Settings password:self.accountNum]);
        NSLog(@"%@",self.account.lastError);
    }
 

    return self;
}

// Returns a singleton ImapSync object; can be used as a global object for storing messages
+(ImapSync *)sharedDataManager
{
	static dispatch_once_t onceToken = 0;
	static ImapSync *dataManager = nil;
	dispatch_once(&onceToken, ^{
		dataManager = [[ImapSync alloc] initWithImapServer];
	});
	return dataManager;
}

-(CTCoreFolder *)createFolder:(NSString *)path
{
    CTCoreFolder *newFolder = [self.account folderWithPath:path];
    [newFolder create];
    return newFolder;
}


-(CTCoreFolder *)getInbox
{
    CTCoreFolder *inbox = [self.account folderWithPath:@"INBOX"];
    return inbox;

}

-(NSSet *)getFolderNames
{
    NSSet *folders = [self.account allFolders];
    return folders;
}

-(NSMutableArray *)getMessagesFirstBatch
{
    // Returns an array of 5 Email Messages

    CTCoreFolder *inbox = [self.account folderWithPath:@"INBOX"];
    NSArray *messages = [inbox messagesFromSequenceNumber:1 to:5 withFetchAttributes:CTFetchAttrEnvelope];
    NSMutableArray *message_array = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < [messages count]; i++) {
        aMessage = [[Message alloc] init];
        aMessage.messageID = i;
        CTCoreMessage *msg  = [messages objectAtIndex:i];
        BOOL isHTML;
        aMessage.sequenceNumber = [msg sequenceNumber];
        aMessage.body = [msg bodyPreferringPlainText:&isHTML];
        aMessage.subject = [msg subject];

        aMessage.senderEmailAddress = [[msg sender] email];
        aMessage.senderName = [[msg sender] name];
        //NSLog(@"%@", aMessage.senderEmailAddress);
        //NSLog(@"%@", aMessage.senderName);
  


        aMessage.uid = [msg uid];
        aMessage.date = [msg senderDate];


        //NSLog(@"displaying body");
        //NSLog(@"%@", aMessage.body);
        [message_array addObject:aMessage];
    }
    
    
    return message_array;
    
}

-(NSMutableArray *)getMessages:(NSUInteger)start:(NSUInteger)finish
{
    // this is nearly the same method as getMessages, but with start and finish arguments
    // TODO: is there a better way to call this (to avoid repeat code)?
    
    CTCoreFolder *inbox = [self.account folderWithPath:@"INBOX"];
    NSArray *messages = [inbox messagesFromSequenceNumber:start to:finish withFetchAttributes:CTFetchAttrEnvelope];
    NSMutableArray *message_array = [[NSMutableArray alloc] init];
      
    for (int i = 0; i < [messages count] - 1; i++) {
        aMessage = [[Message alloc] init];
        aMessage.messageID = i;
        CTCoreMessage *msg  = [messages objectAtIndex:i];
        BOOL isHTML;
        aMessage.sequenceNumber = [msg sequenceNumber];
        aMessage.body = [msg bodyPreferringPlainText:&isHTML];
        aMessage.subject = [msg subject];
        aMessage.senderEmailAddress = [[msg sender] email];
        aMessage.senderName = [[msg sender] name];
        aMessage.date = [msg senderDate];
        
        aMessage.uid = [msg uid];

        
        [message_array addObject:aMessage];
    }
    
    
    return message_array;
}

-(void)filterMessagesAccordingToRules
{
    //TODO: write the code to get the dbManager singleton
    //then get an array of rules from the db table filter_rules
    NSArray *rules = [dbManager getRulesFromDb];
    
    //TODO: run a map-filter function on the rules array with the inbox messages array
}


@end
