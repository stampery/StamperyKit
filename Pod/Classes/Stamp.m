//
//  Stamp.m
//  Stampery
//
//  Created by Pablo Merino on 27/7/15.
//  Copyright (c) 2015 Stampery. All rights reserved.
//

#import "Stamp.h"

@implementation Stamp
-(id) initWithDictionary:(NSDictionary*) stamp {
    self = [super init];
    if(!self)
        return nil;
    
    NSDictionary *stampData = stamp[@"data"];
    NSDictionary *stampProof = stamp[@"proof"];
    
    self.authors = stampData[@"owners"];
    
    NSDateFormatter *df1 = [[NSDateFormatter alloc] init];
    [df1 setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSSZ"];
    NSDate *dtPostDate = [df1 dateFromString:stamp[@"time"]];
    self.date = dtPostDate;
    self.authorsHash = [StamperyHashing sha256OfData:[stamp[@"authorsHash"] dataUsingEncoding:NSStringEncodingConversionExternalRepresentation]];
    self.fileName = stampData[@"name"];
    self.fileSize = [stampData[@"size"] integerValue];
    self.merkleIndex = [stampProof[@"merkleIndex"] integerValue];
    self.stampHash = stampData[@"hash"];
    self.merkleRoot = stampProof[@"merkleRoot"];
    self.merkleSiblings = stampProof[@"merkleSiblings"];
    if([stampProof[@"pending"] isEqual:[NSNull null]]) {
        self.pending = false;
    } else {
        self.pending = (BOOL)[stampProof[@"pending"] boolValue];
    }
    
    self.txId = stampProof[@"txid"];
    self.stored = (BOOL)[stampData[@"stored"] boolValue];
    self.proofHash = stampProof[@"hash"];
    
    self.attributeDictionary = stamp;
    return self;
}

-(StampFileType) fileType {
    NSString *fileExt = [[self.fileName pathExtension] lowercaseString];
    if([@[@"jpg", @"jpeg", @"png", @"gif"] containsObject:fileExt]) {
        return StampFileTypeImage;
    } else if ([@[@"xls", @"xlsx", @"ods", @"csv"] containsObject:fileExt]) {
        return StampFileTypeSpreadsheet;
    } else if ([@[@"mp3", @"wav", @"flac", @"m4a"] containsObject:fileExt]) {
        return StampFileTypeSong;
    } else if ([@[@"mp4", @"ogg", @"avi", @"mkv"] containsObject:fileExt]) {
        return StampFileTypeMovie;
    } else if ([@[@"zip", @"rar", @"7z", @"tar", @"gz"] containsObject:fileExt]) {
        return StampFileTypeCompressedFile;
    }
    return StampFileTypeDocument;
}

@end
