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

- (id)initWithImapServer
{
    NSLog(@"trying to connect...");

    self = [super init];
    self.accountNum = 1;
    self.account = [[CTCoreAccount alloc] init];
    
    /*
    BOOL success = [self.account connectToServer:[Settings server:self.accountNum]
                                            port:[Settings serverPort:self.accountNum]
                                  connectionType:CONNECTION_TYPE_TLS
                                        authType:IMAP_AUTH_TYPE_PLAIN
                                           login:[Settings username:self.accountNum]
                                        password:[Settings password:self.accountNum]];
     */
    
    
    BOOL success = [self.account connectToServer:@"imap.gmail.com"
                                            port:993
                                  connectionType:CONNECTION_TYPE_TLS
                                        authType:IMAP_AUTH_TYPE_PLAIN
                                           login:@"moe@trackpattern.com"
                                        password:@"bl1tz5590"];
     
    /*
    BOOL success = [self.account connectToServer:@"imap.gmail.com"
                                            port:993
                                  connectionType:CONNECTION_TYPE_TLS
                                        authType:IMAP_AUTH_TYPE_PLAIN
                                           login:@"moe@dev70.com"
                                        password:@"bl1tz5590"];
     */
    
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

-(NSUInteger *)getInboxCount
{
    /*
    NSUInteger *total = NULL;
    if ([[self getInbox] totalMessageCount:total])
    {
        return total;
    }
    else
    {
        return -1;
    }
    */
    NSUInteger total = 0;
    if ([[self getInbox] totalMessageCount:&total])
    {
        return total;
    }
    else
    {
        return -1;
    }

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

-(void)filterMessage:(NSUInteger)uid:(CTCoreFolder *)inbox:(NSString *)folderName
{
    NSLog(@"inside filterMessage");

    if ((NSNull *)folderName == [NSNull null])
    {
        NSLog(@"null folder");
    }
    else
    {
        //TODO: check if folder of string folderName exists
        //BOOL success = [inbox moveMessageWithUID:uid toPath:folderName];
        BOOL success = [inbox moveMessageWithUID:uid toPath:folderName];
    
        if (!success)
        {
            NSLog(@"can't move message");
            NSLog(@"%@",self.account.lastError);
        }
        else
        {
            NSLog(@"success!");
        }
    }
        
}

-(void)filterMessagesAccordingToRules
{
    DatabaseModel *dbManager = [DatabaseModel sharedDataManager];

    //NSMutableArray *inboxMessages = [self getMessages:1 :0];
    CTCoreFolder *inbox = [self.account folderWithPath:@"INBOX"];
    NSArray *inboxMessages = [inbox messagesFromSequenceNumber:1 to:0 withFetchAttributes:CTFetchAttrEnvelope];
    
    NSArray *rulesFromDatabaseArray = [dbManager getRules];
    NSDictionary *rules;
    
    //for each rule, search the message array for a subj and/or sender match
    //if a match is found, move it to folder in rule
    for (int i = 0; i < [rulesFromDatabaseArray count]; i++)
    {
        //NSLog(@"looping first");
        rules = [rulesFromDatabaseArray objectAtIndex:i];
       // for (id key in rules)
        //{
          //  NSLog(@"key: %@, value: %@", key, [rules objectForKey:key]);
        //}
       // NSLog(@"%@", [rules objectForKey:@"subj"]);

        for (int j = 0; j < [inboxMessages count]; j++)
        {
            //NSLog(@"looping second");

            //tests for debugging
            /*
            if ([[rules objectForKey:@"subj"] length] > 0)
            {
                NSLog(@"rules element is");
                NSLog(@"%@", [rules objectForKey:@"subj"]);
                
                NSLog(@"inboxMessages element is");
                NSLog(@"%@", [[inboxMessages objectAtIndex:j] subject]);
            }
             */
            
            //filter all subject matches to specified folder based on rule
            if ([[rules objectForKey:@"subj"] isEqualToString:[[inboxMessages objectAtIndex:j] subject]])
            {
                NSLog(@"found a match");

                [self filterMessage:[[inboxMessages objectAtIndex:j] uid]:inbox:[rules objectForKey:@"fldr"]];
            }
            
            //do the same for all sender matches
            if ([[rules objectForKey:@"sndr"] isEqualToString:[[inboxMessages objectAtIndex:j] subject]])
            {
                [self filterMessage:[[inboxMessages objectAtIndex:j] uid]:inbox:[rules objectForKey:@"fldr"]];
            }

        }
    }
}
@end