//
//  StamperyHashing.h
//  Stampery
//
//  Created by Pablo Merino on 25/7/15.
//  Copyright (c) 2015 Stampery. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "StamperyCommons.h"

@interface StamperyHashing : NSObject
+ (NSString*) sha256OfData:(NSData*) data;
@end
