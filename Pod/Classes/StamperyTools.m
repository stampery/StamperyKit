//
//  StamperyTools.m
//  Stampery
//
//  Created by Pablo Merino on 25/7/15.
//  Copyright (c) 2015 Stampery. All rights reserved.
//

#import "StamperyTools.h"

@implementation StamperyTools
+(NSString*)generateUrlForEndpoint:(NSString*)endpoint {
    return [NSString stringWithFormat:@"%@/%@", BASE_URL, endpoint];
}

+(NSString*)generateUrlForEndpoint:(NSString*)endpoint withQueryParams:(NSDictionary*)queryParams {
    
    NSString *generatedUrl = [NSString stringWithFormat:@"%@/%@", BASE_URL, endpoint];
    NSMutableArray *params = [[NSMutableArray alloc] initWithArray:@[]];
    
    for (id key in queryParams) {
        id value = queryParams[key];
        [params addObject:[NSString stringWithFormat:@"%@=%@", key, value]];
    }
    
    NSString *finalParamsString = [params componentsJoinedByString:@"&"];
    
    return [[NSString stringWithFormat:@"%@?%@", generatedUrl, finalParamsString] stringByAddingPercentEncodingWithAllowedCharacters:NSCharacterSet.URLQueryAllowedCharacterSet];
}

+(NSString*)generateBetaUrlForEndpoint:(NSString*)endpoint {
    return [NSString stringWithFormat:@"%@/%@", BASE_URL, endpoint];
}

+(NSError*) generateErrorForString:(NSString*)errorString andErrorCode:(NSInteger)errorCode {
    NSDictionary *errorDesc = @{NSLocalizedDescriptionKey: errorString};
    NSError *err = [NSError errorWithDomain:@"stamperyError" code:errorCode userInfo:errorDesc];
    
    return err;
}

+(NSString*) generateAuthenticationHeaderForToken:(NSString*)token {
    NSData *dataToken = [token dataUsingEncoding:NSUTF8StringEncoding];
    NSString *base64EncodedToken = [[NSString alloc] initWithData:[dataToken base64EncodedDataWithOptions:0] encoding:NSUTF8StringEncoding];
    return [NSString stringWithFormat:@"Basic %@", base64EncodedToken];
}
@end
