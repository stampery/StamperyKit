//
//  User.m
//  Stampery
//
//  Created by Pablo Merino on 21/7/15.
//  Copyright (c) 2015 Pablo Merino. All rights reserved.
//

#import "User.h"

@implementation User
-(id) initWithDictionary:(NSDictionary*) user {
    self = [super init];
    if(!self)
        return nil;
    
    self.bio = user[@"bio"];
    self.location = user[@"location"];
    self.name = user[@"name"];
    self.picture = user[@"picture"];
    self.username = user[@"username"];
    self.attributeDictionary = user;
    
    return self;
}
@end
