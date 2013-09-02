//
//  JAFileSystemCopy.m
//  DataDeposit2
//
//  Created by JUSTIN AMBERSON on 9/2/13.
//  Copyright (c) 2013 justinxxvii. All rights reserved.
//

#import "JAFileSystemCopy.h"
#import "COCopyClient.h"
#import "JAOperationWrapperConstants.h"

@interface JAFileSystemCopy ()
@property (nonatomic,strong) COCopyClient *theCopyClient;
@end

@implementation JAFileSystemCopy

-(void)fetch {
    if (!self.theCopyClient) {
        self.theCopyClient = [[COCopyClient alloc]initWithToken:CopyOAuthToken() andTokenSecret:CopyOAuthSecret()];
    }
    NSMutableString *pathString = [NSMutableString string];
    [pathString appendString:@"/"];
    for (NSString *path in self.pathComponents) {
        [pathString appendString:path];
        if (![[self.pathComponents lastObject]isEqual:path]) {
            [pathString appendString:@"/"];
        }
        
    }
    NSLog(@"Remote path: %@",pathString);
    [self.theCopyClient requestFileSystemListingForPath:pathString withCompletionBlock:^(BOOL success, NSError *error, NSDictionary *fileSystemListing) {
        if (!error) {
            NSLog(@"%@",fileSystemListing);
            NSMutableArray *remoteFiles = [NSMutableArray array];
            NSArray *children = [fileSystemListing objectForKey:@"children"];
            for (NSDictionary *child in children) {
                NSMutableDictionary *dict = [NSMutableDictionary dictionary];
                NSString *fileName = [child objectForKey:@"name"];
                NSString *path = [child objectForKey:@"path"];
                [dict setObject:fileName forKey:JAFileDownloadNameKey];
                [dict setObject:path forKey:JAFileDownloadRemotePathKey];
                [remoteFiles addObject:dict];
            }
            self.completionBlock(remoteFiles);
        } else {
            NSLog(@"Error: %@",error);
            self.failedBlock(error);
        }
    }];
}

@end
