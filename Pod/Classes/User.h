//
//  User.h
//  Stampery
//
//  Created by Pablo Merino on 21/7/15.
//  Copyright (c) 2015 Pablo Merino. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface User : NSObject

@property(nonatomic, strong) NSString *bio;
@property(nonatomic, strong) NSString *name;
@property(nonatomic, strong) NSString *location;
@property(nonatomic, strong) NSString *picture;
@property(nonatomic, strong) NSString *username;
@property(nonatomic, strong) NSDictionary *attributeDictionary;

-(id) initWithDictionary:(NSDictionary*) user;
@end
