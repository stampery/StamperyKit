//
//  StamperyTools.h
//  Stampery
//
//  Created by Pablo Merino on 25/7/15.
//  Copyright (c) 2015 Stampery. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "StamperyCommons.h"
@interface StamperyTools : NSObject
+(NSString*) generateUrlForEndpoint:(NSString*)endpoint;
+(NSString*) generateBetaUrlForEndpoint:(NSString*)endpoint;
+(NSString*) generateUrlForEndpoint:(NSString*)endpoint withQueryParams:(NSDictionary*)queryParams;
+(NSError*) generateErrorForString:(NSString*)errorString andErrorCode:(NSInteger)errorCode;
+(NSString*) generateAuthenticationHeaderForToken:(NSString*)token;
@end
