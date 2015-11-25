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
    NSString *hash = [[data SHA256] description];
    hash = [hash stringByReplacingOccurrencesOfString:@" " withString:@""];
    hash = [hash stringByReplacingOccurrencesOfString:@"<" withString:@""];
    hash = [hash stringByReplacingOccurrencesOfString:@">" withString:@""];
    return hash;
}
@end
