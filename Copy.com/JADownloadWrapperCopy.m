//
//  JADownloadWrapperCopy.m
//  DataDeposit2
//
//  Created by JUSTIN AMBERSON on 9/2/13.
//  Copyright (c) 2013 justinxxvii. All rights reserved.
//

#import "JADownloadWrapperCopy.h"
#import "JAOperationWrapperConstants.h"
#import "COCopyClient.h"
@interface JADownloadWrapperCopy ()
@property (nonatomic,strong) COCopyClient *theCopyClient;
@end

@implementation JADownloadWrapperCopy

-(void)download {
    if (!self.theCopyClient) {
        self.theCopyClient = [[COCopyClient alloc]initWithToken:CopyOAuthToken() andTokenSecret:CopyOAuthSecret()];
    }
    [self.pathsDictionary setObject:@"Copy.com" forKey:JAFileDownloadServiceNameKey];
    NSString *fileName = [self.pathsDictionary objectForKey:JAFileDownloadNameKey];
    NSString *remotePath = [self.pathsDictionary objectForKey:JAFileDownloadRemotePathKey];
    NSString *localPath = [self.pathsDictionary objectForKey:JAFileDownloadLocalPathKey];
    NSString *filePath = [localPath stringByAppendingPathComponent:fileName];
    [self.theCopyClient downloadPath:remotePath toFilePath:filePath withProgressBlock:^(long long downloadedSoFar, long long expectedContentLength) {
        CGFloat prog = (CGFloat)downloadedSoFar/(CGFloat)expectedContentLength;
        NSNumber *perc = [NSNumber numberWithFloat:prog];
        [self.pathsDictionary setObject:perc forKey:JAFileDownloadPercentageKey];
        self.progressBlock(self.pathsDictionary);
    } andCompletionBlock:^(BOOL success, NSError *error) {
        if (!error) {
            [self.pathsDictionary setObject:[NSDate date] forKey:JAFileDownloadDateKey];
            self.completedBlock(self.pathsDictionary);
        } else {
            self.failedBlock(error);
        }
    }];
}

@end
