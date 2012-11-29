//
//  Settings.m
//  GetMailSimple
//
//  Created by Moe Burney on 2012-10-28.
//  Copyright (c) 2012 Dev70. All rights reserved.
//

#import "Settings.h"

@implementation Settings

+(NSString*)server:(int)accountNum {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults stringForKey:[NSString stringWithFormat:@"server_%i", accountNum]];
}

+(void)setServer:(NSString*)value accountNum:(int)accountNum {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:value forKey:[NSString stringWithFormat:@"server_%i", accountNum]];
    [NSUserDefaults resetStandardUserDefaults];
}

+(int)serverEncryption:(int)accountNum {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults integerForKey:[NSString stringWithFormat:@"server_encryption_%i", accountNum]];
}

+(void)setServerEncryption:(int)type accountNum:(int)accountNum {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setInteger:type forKey:[NSString stringWithFormat:@"server_encryption_%i", accountNum]];
    [NSUserDefaults resetStandardUserDefaults];
}

+(int)serverPort:(int)accountNum {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults integerForKey:[NSString stringWithFormat:@"server_port_%i", accountNum]];
}

+(void)setServerPort:(int)port accountNum:(int)accountNum {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setInteger:port forKey:[NSString stringWithFormat:@"server_port_%i", accountNum]];
    [NSUserDefaults resetStandardUserDefaults];
}

+(int)serverAuthentication:(int)accountNum {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults integerForKey:[NSString stringWithFormat:@"server_authentication_%i", accountNum]];
}

+(void)setServerAuthentication:(int)type accountNum:(int)accountNum {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setInteger:type forKey:[NSString stringWithFormat:@"server_authentication_%i", accountNum]];
    [NSUserDefaults resetStandardUserDefaults];
}

+(NSString*)username:(int)accountNum {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString* usernamePreference = [defaults stringForKey:[NSString stringWithFormat:@"username_%i", accountNum]];
    
    return usernamePreference;
}

+(void)setUsername:(NSString*)y accountNum:(int)accountNum {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:y forKey:[NSString stringWithFormat:@"username_%i", accountNum]];
    [NSUserDefaults resetStandardUserDefaults];
}

+(NSString*)password:(int)accountNum{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString* passwordPreference = [defaults stringForKey:[NSString stringWithFormat:@"password_%i", accountNum]];
    
    return passwordPreference;
}

+(void)setPassword:(NSString*)y accountNum:(int)accountNum {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:y forKey:[NSString stringWithFormat:@"password_%i", accountNum]];
    [NSUserDefaults resetStandardUserDefaults];
}

@end


