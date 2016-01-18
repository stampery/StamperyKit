//
//  StamperyCommons.h
//  Stampery
//
//  Created by Pablo Merino on 25/7/15.
//  Copyright (c) 2015 Stampery. All rights reserved.
//

#import <AFNetworking/AFNetworking.h>
#import <NSHash/NSData+NSHash.h>
#import <SSKeychain/SSKeychain.h>
#import "User.h"
#import "Stamp.h"
#import "Profile.h"
#import "PreStamp.h"
#import "StamperySession.h"
#import "StamperyTools.h"
#import "StamperyHashing.h"

#define PRODUCTION_V1_BASE_URL @"https://stampery.co/api/v1"
#define BASE_URL @"https://api.stampery.com/v2"

#define TOKEN_NAME @"Stampery iOS App"

#define STAMPERY_KEYCHAIN @"stampery-ios"
#define STAMPERY_USERDEFAULTS @"stampery-ios-user"