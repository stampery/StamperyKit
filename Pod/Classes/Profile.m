//
//  Profile.m
//  Stampery
//
//  Created by Pablo Merino on 5/8/15.
//  Copyright (c) 2015 Stampery. All rights reserved.
//

#import "Profile.h"

@implementation Profile
-(id) initWithDictionary:(NSDictionary*) profile {
    self = [super init];
    if(!self)
        return nil;
    
    self.fullName = profile[@"name"];
    self.emailAddress = profile[@"email"];
    self.userName = profile[@"username"];
    self.location = profile[@"location"];
    self.bio = profile[@"bio"];
    self.profilePicture = profile[@"picture"];
    
    return self;
}

-(void) downloadProfilePictureWithCompletionBlock:(void (^)(UIImage *profilePicture)) completionBlock {
    NSURL *url = [NSURL URLWithString:self.profilePicture];
    
    dispatch_queue_t downloadQueue = dispatch_queue_create("co.stampery.profilepicturedownloader", NULL);
    dispatch_async(downloadQueue, ^{
        NSData * imageData = [NSData dataWithContentsOfURL:url];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            completionBlock([UIImage imageWithData:imageData]);
        });
    });
}

-(void) setValue:(id)value forProperty:(NSString*) property {
    if (value) {
        [self setValue:value forKey:property];
    }
}
@end
