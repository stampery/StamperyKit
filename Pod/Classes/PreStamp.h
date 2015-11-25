//
//  PreStamp.h
//  Stampery
//
//  Created by Pablo Merino on 7/9/15.
//  Copyright (c) 2015 Stampery. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PreStamp : NSObject
@property(nonatomic, strong) NSArray *authors;
@property(nonatomic, strong) NSString *fileHash;
@property(nonatomic, strong) NSString *fileName;
@property(nonatomic) NSInteger fileSize;
@property(nonatomic, strong) NSData *fileData;

-(id) initWithDictionary:(NSDictionary*) stamp;
@end
