//
//  StamperySession.m
//  Stampery
//
//  Created by Pablo Merino on 25/7/15.
//  Copyright (c) 2015 Stampery. All rights reserved.
//

#import "StamperySession.h"

@implementation StamperySession
-(id) initWithUserToken:(NSString*) userToken andEmail:(NSString*)email {
    self = [super init];
    if(!self)
        return nil;
    
    self.userEmail = email;
    self.userToken = userToken;
    
    return self;
}

-(id) initWithKeychainUser:(NSString*) user {
    self = [super init];
    if(!self)
        return nil;
    
    [SSKeychain passwordForService:STAMPERY_KEYCHAIN account:user];
    
    self.userEmail = user;
    self.userToken = [SSKeychain passwordForService:STAMPERY_KEYCHAIN account:user];
    
    return self;
}

-(void) saveUserToken {
    [[[NSUserDefaults alloc] initWithSuiteName:@"group.stampery"] setObject:[NSKeyedArchiver archivedDataWithRootObject:self.userEmail] forKey:STAMPERY_USERDEFAULTS];
    [SSKeychain setPassword:self.userToken forService:STAMPERY_KEYCHAIN account:self.userEmail];
}

@end
