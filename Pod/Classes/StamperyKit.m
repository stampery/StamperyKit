//
//  StamperyKit.m
//  Stampery
//
//  Created by Pablo Merino on 21/7/15.
//  Copyright (c) 2015 Pablo Merino. All rights reserved.
//

#import "StamperyKit.h"

@implementation StamperyKit

//
// Implements a singleton object
//
+(instancetype) sharedInstance {
    static dispatch_once_t once;
    static id sharedInstance;
    
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];
    });
    
    return sharedInstance;
}

-(id)init {
    self = [super init];
    
    if(self) {
        self.retries = 3;
        self.queue = [[NSOperationQueue alloc] init];
        
        self.requestManager = [AFHTTPRequestOperationManager manager];

        self.requestManager.requestSerializer = [AFJSONRequestSerializer serializer];
        self.requestManager.responseSerializer.acceptableContentTypes = [NSSet setWithArray:@[@"text/html", @"application/json"]];
        
        NSData *_data = [[[NSUserDefaults alloc] initWithSuiteName:@"group.stampery"] objectForKey:STAMPERY_USERDEFAULTS];
        NSString *userEmail = [NSKeyedUnarchiver unarchiveObjectWithData:_data];
        
        if(userEmail) {
            self.userSession = [[StamperySession alloc] initWithKeychainUser:userEmail];
            [self getUserProfileWithCompletionBlock:^(id profile){
                if ([profile isKindOfClass:[Profile class]]) {
                    self.userProfile = profile;
                }
            } errorBlock:nil];
        }
    }
    
    return self;
}

//
// Method to sign a file
//

-(void) stampFile:(PreStamp*)preStamp backupFile:(BOOL)backup completion:(void (^)(id response)) completionBlock errorBlock:(void (^)(NSError *error)) errorBlock {
    if(self.retries <= 0) {
        if(errorBlock)
            return errorBlock([StamperyTools generateErrorForString:@"Error requesting the server" andErrorCode:1010]);
    } else {
        [self internalStampFile:preStamp backupFile:backup completion:^(id response) {
            if(completionBlock) {
                self.retries = 3;
                return completionBlock(response);
            }
        } errorBlock:^(NSError *error) {
            self.retries--;
        }];
    }
}

-(void) internalStampFile:(PreStamp*)preStamp backupFile:(BOOL)backup completion:(void (^)(id response)) completionBlock errorBlock:(void (^)(NSError *error)) errorBlock {
    if(self.userSession) {
        [self.requestManager.requestSerializer setValue:[StamperyTools generateAuthenticationHeaderForToken:[self.userSession userToken]] forHTTPHeaderField:@"Authorization"];
        NSError *jsonError;
        NSDictionary *jsonData = @{@"owners":preStamp.authors, @"size": [NSNumber numberWithLong:preStamp.fileSize], @"name": preStamp.fileName, @"hash":preStamp.fileHash, @"stored":  @(backup)};
        if(jsonError) {
            if(errorBlock) {
                errorBlock(jsonError);
            }
        }
        if(backup) {
            [self.requestManager POST:[StamperyTools generateUrlForEndpoint:@"stamps"] parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
                NSError *jsonError;
                NSData *jsonSerializedData = [NSJSONSerialization dataWithJSONObject:jsonData options:NSJSONWritingPrettyPrinted error:&jsonError];
                if(jsonError) {
                    if(errorBlock) {
                        errorBlock(jsonError);
                    }
                }
                [formData appendPartWithFormData:jsonSerializedData name:@"data"];
                [formData appendPartWithFileData:preStamp.fileData name:@"file" fileName:preStamp.fileName mimeType:@"application/octet-stream"];
            } success:^(AFHTTPRequestOperation *operation, id responseObject) {
                if(completionBlock)
                    completionBlock(responseObject);
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                if(errorBlock)
                    errorBlock(error);
            }];
        } else {
            [self.requestManager POST:[StamperyTools generateUrlForEndpoint:@"stamps"] parameters:jsonData success:^(AFHTTPRequestOperation *operation, id responseObject) {
                if(completionBlock)
                    completionBlock(responseObject);
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                if(errorBlock)
                    errorBlock(error);
            }];
        }
    } else {
        errorBlock([StamperyTools generateErrorForString:@"The user token is not set" andErrorCode:1000]);
    }
}

//
// Gets the details of a stamp
//
-(void) detailsForStampHash:(NSString*) fileHash completion:(void (^)(id response))completionBlock errorBlock:(void (^)(NSError *error)) errorBlock {
    [self.requestManager GET:[NSString stringWithFormat:@"%@/stamps/%@", BASE_URL, fileHash] parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if([responseObject isKindOfClass:[NSDictionary class]]) {
            if(responseObject[@"err"]) {
                errorBlock([StamperyTools generateErrorForString:@"Not a valid stamp" andErrorCode:1005]);

            } else {
                if(completionBlock)
                    completionBlock([[Stamp alloc] initWithDictionary:responseObject]);
            }
        } else {
            if(errorBlock)
                errorBlock([StamperyTools generateErrorForString:@"Not a valid stamp" andErrorCode:1005]);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if(errorBlock)
            errorBlock(error);
    }];
}


//
// Logins an user/password and returns the user token
//
-(void) loginWithEmail:(NSString*) email andPassword:(NSString*)password completion:(void (^)(id response)) completionBlock errorBlock:(void (^)(NSError *error)) errorBlock {
    if(self.userSession) {
        return;
    }
    NSData *loginParams = [NSJSONSerialization dataWithJSONObject:@{@"email":email, @"password":password, @"ios": @YES} options:NSJSONWritingPrettyPrinted error:nil];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[StamperyTools generateUrlForEndpoint:@"login"]] cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:10];
    
    [request setHTTPMethod:@"POST"];
    [request setValue: @"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody: loginParams];
    AFHTTPRequestOperation *op = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    op.responseSerializer = [AFJSONResponseSerializer serializer];
    [op setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        if(responseObject[@"err"]) {
            errorBlock([StamperyTools generateErrorForString:responseObject[@"err"] andErrorCode:1002]);
        } else {
            self.userSession = [[StamperySession alloc] initWithUserToken:[NSString stringWithFormat:@"%@:%@", responseObject[@"api_token"][@"clientId"], responseObject[@"api_token"][@"secretToken"]] andEmail:email];
            [self.userSession saveUserToken];
            [self getUserProfileWithCompletionBlock:^(id profile){
                if ([profile isKindOfClass:[Profile class]]) {
                    self.userProfile = profile;
                }
            } errorBlock:nil];

            if(completionBlock)
                completionBlock(responseObject);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if(errorBlock)
            errorBlock(error);
    }];
    [op start];
}

//
// Logins an user/password and OTP and returns the user token
//
-(void) loginWithEmail:(NSString*) email andPassword:(NSString*)password andOtp:(NSString*)otpCode completion:(void (^)(id response)) completionBlock errorBlock:(void (^)(NSError *error)) errorBlock {
    if(self.userSession) {
        return;
    }
    NSData *loginParams = [NSJSONSerialization dataWithJSONObject:@{@"email":email, @"password":password, @"otp": otpCode, @"ios":@YES} options:NSJSONWritingPrettyPrinted error:nil];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[StamperyTools generateUrlForEndpoint:@"login"]] cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:10];
    
    [request setHTTPMethod:@"POST"];
    [request setValue: @"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody: loginParams];
    AFHTTPRequestOperation *op = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    op.responseSerializer = [AFJSONResponseSerializer serializer];
    [op setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        if(responseObject[@"err"]) {
            errorBlock([StamperyTools generateErrorForString:responseObject[@"err"] andErrorCode:1002]);
        } else {
            self.userSession = [[StamperySession alloc] initWithUserToken:[NSString stringWithFormat:@"%@:%@", responseObject[@"api_token"][@"clientId"], responseObject[@"api_token"][@"secretToken"]] andEmail:email];
            [self.userSession saveUserToken];
            if(completionBlock)
                completionBlock(responseObject);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if(errorBlock)
            errorBlock(error);
    }];
    [op start];
}

//
// Registers an user/password and returns the user token
//
-(void) registerWithEmail:(NSString*) email password:(NSString*)password name:(NSString*)name completion:(void (^)(id response)) completionBlock errorBlock:(void (^)(NSError *error)) errorBlock {
    if(self.userSession) {
        return;
    }
    NSData *loginParams = [NSJSONSerialization dataWithJSONObject:@{@"email":email, @"password":password, @"name":name, @"ios":@YES} options:NSJSONWritingPrettyPrinted error:nil];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[StamperyTools generateUrlForEndpoint:@"signup"]] cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:10];

    [request setHTTPMethod:@"POST"];
    [request setValue: @"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody: loginParams];
    
    AFHTTPRequestOperation *op = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    op.responseSerializer = [AFJSONResponseSerializer serializer];
    [op setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        if(!responseObject[@"err"]) {
            self.userSession = [[StamperySession alloc] initWithUserToken:[NSString stringWithFormat:@"%@:%@", responseObject[@"clientId"], responseObject[@"secretToken"]] andEmail:email];
            [self.userSession saveUserToken];
            [self getUserProfileWithCompletionBlock:^(id profile){
                if ([profile isKindOfClass:[Profile class]]) {
                    self.userProfile = profile;
                }
            } errorBlock:nil];
            if(completionBlock)
                completionBlock(responseObject);
        } else {
            if(errorBlock)
                errorBlock([StamperyTools generateErrorForString:@"Error receiving response from the server" andErrorCode:1005]);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if(errorBlock)
            errorBlock(error);
    }];
    [op start];
}

-(void) listStampsWithLimit:(long)limit AndOffset:(long)offset WithCompletion:(void (^)(id response)) completionBlock errorBlock:(void (^)(NSError *error)) errorBlock {
    if(self.userSession) {
        [self.requestManager.requestSerializer setValue:[StamperyTools generateAuthenticationHeaderForToken:[self.userSession userToken]] forHTTPHeaderField:@"Authorization"];
        NSMutableArray *responseArray = [[NSMutableArray alloc] initWithArray:@[]];
        [self.requestManager GET:[StamperyTools generateUrlForEndpoint:@"stamps" withQueryParams:@{@"limit":[NSNumber numberWithLong:limit], @"offset":[NSNumber numberWithLong:offset]}] parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
            if([responseObject isKindOfClass:[NSDictionary class]]) {
                if([responseObject[@"stamps"] isKindOfClass:[NSArray class]]) {
                    for (id stampDictionary in responseObject[@"stamps"]) {
                        [responseArray addObject:[[Stamp alloc] initWithDictionary:stampDictionary]];
                    }
                }
            } else {
                if(errorBlock)
                    errorBlock([StamperyTools generateErrorForString:@"The response is malformed" andErrorCode:1001]);
            }
            if(completionBlock)
                completionBlock(responseArray);
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            if(errorBlock)
                errorBlock(error);
        }];
    } else {
        if (errorBlock)
            errorBlock([StamperyTools generateErrorForString:@"The user token is not set" andErrorCode:1000]);
    }

}

//
// Lists the user's stamps
//
-(void) listStampsWithCompletion:(void (^)(id response)) completionBlock errorBlock:(void (^)(NSError *error)) errorBlock {
    if(self.userSession) {
        [self.requestManager.requestSerializer setValue:[StamperyTools generateAuthenticationHeaderForToken:[self.userSession userToken]] forHTTPHeaderField:@"Authorization"];
        NSMutableArray *responseArray = [[NSMutableArray alloc] initWithArray:@[]];
        [self.requestManager GET:[StamperyTools generateUrlForEndpoint:@"stamps"] parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
            if([responseObject isKindOfClass:[NSDictionary class]]) {
                if([responseObject[@"stamps"] isKindOfClass:[NSArray class]]) {
                    for (id stampDictionary in responseObject[@"stamps"]) {
                        [responseArray addObject:[[Stamp alloc] initWithDictionary:stampDictionary]];
                    }
                }
            } else {
                if(errorBlock)
                    errorBlock([StamperyTools generateErrorForString:@"The response is malformed" andErrorCode:1001]);
            }
            if(completionBlock)
                completionBlock(responseArray);
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            if(errorBlock)
                errorBlock(error);
        }];
    } else {
        if (errorBlock)
            errorBlock([StamperyTools generateErrorForString:@"The user token is not set" andErrorCode:1000]);
    }
}

//
// Queries the user stamps to search them
//
-(void) queryStamps:(NSString *)query withCompletionBlock:(void (^)(id response)) completionBlock errorBlock:(void (^)(NSError *error)) errorBlock {
    if(self.userSession) {
        [self.requestManager.requestSerializer setValue:[StamperyTools generateAuthenticationHeaderForToken:[self.userSession userToken]] forHTTPHeaderField:@"Authorization"];
        NSMutableArray *responseArray = [[NSMutableArray alloc] initWithArray:@[]];
        [self.requestManager GET:[StamperyTools generateUrlForEndpoint:@"stamps" withQueryParams:@{@"q":query}] parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
            if([responseObject isKindOfClass:[NSDictionary class]]) {
                if([responseObject[@"stamps"] isKindOfClass:[NSArray class]]) {
                    for (id stampDictionary in responseObject[@"stamps"]) {
                        [responseArray addObject:[[Stamp alloc] initWithDictionary:stampDictionary]];
                    }
                }
            } else {
                if(errorBlock)
                    errorBlock([StamperyTools generateErrorForString:@"The response is malformed" andErrorCode:1001]);
            }
            if(completionBlock)
                completionBlock(responseArray);
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            if(errorBlock)
                errorBlock(error);
        }];
    } else {
        if(errorBlock)
            errorBlock([StamperyTools generateErrorForString:@"The user token is not set" andErrorCode:1000]);
    }
}

//
// Queries the user profile data
//
-(void) getUserProfileWithCompletionBlock:(void (^)(id response)) completionBlock errorBlock:(void (^)(NSError *error)) errorBlock {
    if(self.userSession) {
        [self.requestManager.requestSerializer setValue:[StamperyTools generateAuthenticationHeaderForToken:[self.userSession userToken]] forHTTPHeaderField:@"Authorization"];

        [self.requestManager GET:[StamperyTools generateUrlForEndpoint:@"user"] parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
            if([responseObject isKindOfClass:[NSDictionary class]]) {
                if([responseObject[@"user"] isKindOfClass:[NSDictionary class]]) {
                    if(completionBlock)
                        completionBlock([[Profile alloc] initWithDictionary:responseObject[@"user"]]);
                } else {
                    if(errorBlock)
                        errorBlock([StamperyTools generateErrorForString:@"There was an error processing the request" andErrorCode:1002]);
                }
            } else {
                if(errorBlock)
                    errorBlock([StamperyTools generateErrorForString:@"The response is malformed" andErrorCode:1001]);
            }
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            if(errorBlock)
                errorBlock(error);
        }];
        
    } else {
        if(errorBlock)
            errorBlock([StamperyTools generateErrorForString:@"The user token is not set" andErrorCode:1000]);
    }
}

//
// Log out method
//
-(void) logOutOfSessionWithCompletionBlock:(void (^)(bool success)) completionBlock {
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:STAMPERY_USERDEFAULTS];
    if(completionBlock)
        completionBlock([SSKeychain deletePasswordForService:STAMPERY_KEYCHAIN account:self.userSession.userEmail]);
    self.userSession = nil;
    self.userProfile = nil;
}

//
// Method to update profile data
//
-(void) updateUserProfileInfo:(NSDictionary*)userInfo WithCompletionBlock:(void (^)(id response)) completionBlock errorBlock:(void (^)(NSError *error)) errorBlock {
    
    if(self.userSession && userInfo) {
        NSData *newUserProfileData = [NSJSONSerialization dataWithJSONObject:userInfo options:NSJSONWritingPrettyPrinted error:nil];
        
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[StamperyTools generateUrlForEndpoint:@"user"]] cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:10];
        
        [request setHTTPMethod:@"PATCH"];
        [request setValue: @"application/json" forHTTPHeaderField:@"Content-Type"];
        [self.requestManager.requestSerializer setValue:[StamperyTools generateAuthenticationHeaderForToken:[self.userSession userToken]] forHTTPHeaderField:@"Authorization"];
        [request setHTTPBody: newUserProfileData];
        
        AFHTTPRequestOperation *op = [[AFHTTPRequestOperation alloc] initWithRequest:request];
        op.responseSerializer = [AFJSONResponseSerializer serializer];
        [op setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
            if(completionBlock)
                completionBlock(responseObject);
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            if(errorBlock)
                errorBlock(error);
        }];
        [self.queue addOperation:op];
    } else {
        if(errorBlock)
            errorBlock([StamperyTools generateErrorForString:@"The user token is not set" andErrorCode:1000]);
    }
}

-(void) deleteStampWithId:(NSString*)stampId WithCompletionBlock:(void (^)(id response)) completionBlock errorBlock:(void (^)(NSError *error)) errorBlock {
    if(self.userSession) {
        [self.requestManager.requestSerializer setValue:[StamperyTools generateAuthenticationHeaderForToken:[self.userSession userToken]] forHTTPHeaderField:@"Authorization"];
        
        [self.requestManager DELETE:[StamperyTools generateUrlForEndpoint:[NSString stringWithFormat:@"stamps/%@", stampId]] parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
            if(completionBlock)
                completionBlock(responseObject);
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            if(errorBlock)
                errorBlock(error);
        }];

    } else {
        if(errorBlock)
            errorBlock([StamperyTools generateErrorForString:@"The user token is not set" andErrorCode:1000]);
    }

}

@end
