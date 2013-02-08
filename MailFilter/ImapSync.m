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
#import "DatabaseModel.h"
#import <MailCore/MailCore.h>


@implementation ImapSync

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

-(void)filterMessage:(NSUInteger)sequenceNumber:(NSString *)folderName
{
    CTCoreFolder *inbox = [self.account folderWithPath:@"INBOX"];
    
    //TODO: this is fetching a sequence number instead of UID, fix this
    [inbox moveMessageWithUID:sequenceNumber toPath:folderName];

}

-(void)filterMessagesAccordingToRules
{
    DatabaseModel *dbManager = [DatabaseModel sharedDataManager];

    NSMutableArray *inboxMessages = [self getMessages:1 :0];
    
    //TODO: getRules needs to return more than one row
    //TODO: getRules needs to return an array of dicts
    NSArray *rulesArray = [dbManager getRules];
    NSDictionary *rules;
    
    //for each rule, search the message array for a subj and/or sender match
    //if a match is found, move it to folder in rule
    for (int i = 0; i < [rulesArray count]; i++)
    {
        rules = [rulesArray objectAtIndex:i];
        for (int j = 0; j < [inboxMessages count]; j++)
        {
            //filter all subject matches to specified folder based on rule            
            if ([rules objectForKey:@"subj"] == [[inboxMessages objectAtIndex:j] subject])
            {
                [self filterMessage:j:[rules objectForKey:@"fldr"]];
            }
            
            //do the same for all sender matches
            if ([rules objectForKey:@"sndr"] == [[inboxMessages objectAtIndex:j] senderEmailAddress])
            {
                [self filterMessage:j:[rules objectForKey:@"fldr"]];
            }

        }
    }
}
                 
                 
@end