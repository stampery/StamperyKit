//
//  StamperyKit.h
//  Stampery
//
//  Created by Pablo Merino on 21/7/15.
//  Copyright (c) 2015 Pablo Merino. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "StamperyCommons.h"

@interface StamperyKit : NSObject
@property(nonatomic,strong) StamperySession *userSession;
@property(nonatomic,strong) Profile *userProfile;
@property(nonatomic,strong) AFHTTPRequestOperationManager *requestManager;
@property(nonatomic,strong) NSOperationQueue *queue;
@property(nonatomic) int retries;

+(instancetype) sharedInstance;

-(void) stampFile:(PreStamp*)preStamp backupFile:(BOOL)backup completion:(void (^)(id response)) completionBlock errorBlock:(void (^)(NSError *error)) errorBlock;

-(void) detailsForStampHash:(NSString*) fileHash completion:(void (^)(id response)) completionBlock errorBlock:(void (^)(NSError *error)) errorBlock;

-(void) loginWithEmail:(NSString*) email andPassword:(NSString*)password completion:(void (^)(id response)) completionBlock errorBlock:(void (^)(NSError *error)) errorBlock;

-(void) loginWithEmail:(NSString*) email andPassword:(NSString*)password andOtp:(NSString*)otpCode completion:(void (^)(id response)) completionBlock errorBlock:(void (^)(NSError *error)) errorBlock;

-(void) listStampsWithCompletion:(void (^)(id response)) completionBlock errorBlock:(void (^)(NSError *error)) errorBlock;

-(void) listStampsWithLimit:(long)limit AndOffset:(long)offset WithCompletion:(void (^)(id response)) completionBlock errorBlock:(void (^)(NSError *error)) errorBlock;

-(void) registerWithEmail:(NSString*) email password:(NSString*)password name:(NSString*)name completion:(void (^)(id response)) completionBlock errorBlock:(void (^)(NSError *error)) errorBlock;

-(void) queryStamps:(NSString *)query withCompletionBlock:(void (^)(id response)) completionBlock errorBlock:(void (^)(NSError *error)) errorBlock;

-(void) getUserProfileWithCompletionBlock:(void (^)(id response)) completionBlock errorBlock:(void (^)(NSError *error)) errorBlock;

-(void) logOutOfSessionWithCompletionBlock:(void (^)(bool success)) completionBlock;

-(void) updateUserProfileInfo:(NSDictionary*)userInfo WithCompletionBlock:(void (^)(id response)) completionBlock errorBlock:(void (^)(NSError *error)) errorBlock;

-(void) deleteStampWithId:(NSString*)stampId WithCompletionBlock:(void (^)(id response)) completionBlock errorBlock:(void (^)(NSError *error)) errorBlock;

@end
