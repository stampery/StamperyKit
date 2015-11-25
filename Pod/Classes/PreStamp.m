//
//  PreStamp.m
//  Stampery
//
//  Created by Pablo Merino on 7/9/15.
//  Copyright (c) 2015 Stampery. All rights reserved.
//

#import "PreStamp.h"

@implementation PreStamp
-(id) initWithDictionary:(NSDictionary*) file {
    self = [super init];
    if(!self)
        return nil;
    
    self.authors = file[@"authors"];
    self.fileData = file[@"fileData"];
    self.fileHash = file[@"fileHash"];
    self.fileName = file[@"fileName"];
    self.fileSize = [file[@"fileSize"] integerValue];
    return self;
}

@end
