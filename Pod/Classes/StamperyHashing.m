//
//  StamperyHashing.m
//  Stampery
//
//  Created by Pablo Merino on 25/7/15.
//  Copyright (c) 2015 Stampery. All rights reserved.
//

#import "StamperyHashing.h"

@implementation StamperyHashing
+ (NSString*) sha256OfData:(NSData*) data {
    uint8_t digest[CC_SHA256_DIGEST_LENGTH] = {0};
    CC_SHA256(data.bytes, (CC_LONG)data.length, digest);
    NSData *outData = [NSData dataWithBytes:digest length:CC_SHA256_DIGEST_LENGTH];
    NSString *hash = [outData description];
    hash = [hash stringByReplacingOccurrencesOfString:@" " withString:@""];
    hash = [hash stringByReplacingOccurrencesOfString:@"<" withString:@""];
    hash = [hash stringByReplacingOccurrencesOfString:@">" withString:@""];
    return hash;
}
@end
