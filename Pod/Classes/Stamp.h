//
//  Stamp.h
//  Stampery
//
//  Created by Pablo Merino on 27/7/15.
//  Copyright (c) 2015 Stampery. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "StamperyCommons.h"
typedef enum : NSUInteger {
    StampFileTypeImage,
    StampFileTypeDocument,
    StampFileTypeSpreadsheet,
    StampFileTypeMovie,
    StampFileTypeSong,
    StampFileTypeCompressedFile
} StampFileType;

@interface Stamp : NSObject
@property(nonatomic, strong) NSArray *authors;
@property(nonatomic, strong) NSDate *date;
@property(nonatomic, strong) NSString *fileHash;
@property(nonatomic, strong) NSString *fileName;
@property(nonatomic) NSInteger fileSize;
@property(nonatomic) NSInteger merkleIndex;
@property(nonatomic, strong) NSString *merkleRoot;
@property(nonatomic, strong) NSString *authorsHash;
@property(nonatomic, strong) NSString *stampHash;
@property(nonatomic, strong) NSArray *merkleSiblings;
@property(nonatomic) BOOL pending;
@property(nonatomic, strong) NSString *shortId;
@property(nonatomic) BOOL stored;
@property(nonatomic) BOOL email;
@property(nonatomic, strong) NSString *txId;
@property(nonatomic, strong) NSString *proofHash;

@property(nonatomic, strong) NSDictionary *attributeDictionary;


-(id) initWithDictionary:(NSDictionary*) stamp;
-(StampFileType) fileType;
@end
