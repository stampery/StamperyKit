//
//  Profile.h
//  Stampery
//
//  Created by Pablo Merino on 5/8/15.
//  Copyright (c) 2015 Stampery. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface Profile : NSObject
@property(nonatomic, strong) NSString *fullName;
@property(nonatomic, strong) NSString *userName;
@property(nonatomic, strong) NSString *emailAddress;
@property(nonatomic, strong) NSString *location;
@property(nonatomic, strong) NSString *bio;
@property(nonatomic, strong) NSString *profilePicture;
@property(nonatomic) NSInteger userId;

@property(nonatomic, strong) NSDictionary *attributeDictionary;


-(id) initWithDictionary:(NSDictionary*) stamp;
-(void) downloadProfilePictureWithCompletionBlock:(void (^)(UIImage *profilePicture)) completionBlock;
-(void) setValue:(id)value forProperty:(NSString*) property;
@end
