//
//  Message.h
//  MailFilter
//
//  Created by Moe Burney on 2012-11-27.
//  Copyright (c) 2012 Dev70. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Message : NSObject

@property (nonatomic) NSInteger messageID;
@property (nonatomic) NSUInteger sequenceNumber;
@property (nonatomic) NSString *body;
@property (nonatomic) NSString *from;
@property (nonatomic) NSString *subject;
@property (nonatomic) NSString *date;

@end
