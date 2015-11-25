//
//  StamperySession.h
//  Stampery
//
//  Created by Pablo Merino on 25/7/15.
//  Copyright (c) 2015 Stampery. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "StamperyCommons.h"
@interface StamperySession : NSObject
@property(nonatomic, strong) NSString *userToken;
@property(nonatomic, strong) NSString *userEmail;
-(id) initWithUserToken:(NSString*) userToken andEmail:(NSString*)email;
-(id) initWithKeychainUser:(NSString*) user;
-(void) saveUserToken;
@end
