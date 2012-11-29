//
//  Settings.h
//  GetMailSimple
//
//  Created by Moe Burney on 2012-10-28.
//  Copyright (c) 2012 Dev70. All rights reserved.
//

#import <Foundation/Foundation.h>



@interface Settings : NSObject {
}

// data about accounts

+(NSString*)server:(int)accountNum;
+(void)setServer:(NSString*)value accountNum:(int)accountNum;
+(int)serverEncryption:(int)accountNum;
+(void)setServerEncryption:(int)type accountNum:(int)accountNum;
+(int)serverPort:(int)accountNum;
+(void)setServerPort:(int)port accountNum:(int)accountNum;
+(int)serverAuthentication:(int)accountNum;
+(void)setServerAuthentication:(int)type accountNum:(int)accountNum;
+(NSString*)username:(int)accountNum;
+(void)setUsername:(NSString*)y accountNum:(int)accountNum;
+(NSString*)password:(int)accountNum;
+(void)setPassword:(NSString*)y accountNum:(int)accountNum;

@end

