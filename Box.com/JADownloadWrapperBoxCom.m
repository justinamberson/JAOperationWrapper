//
//  JADownloadWrapperBoxCom.m
//  DataDeposit2
//
//  Created by JUSTIN AMBERSON on 8/25/13.
//  Copyright (c) 2013 justinxxvii. All rights reserved.
//

#import "JADownloadWrapperBoxCom.h"
#import <BoxSDK/BoxSDK.h>
#import "JAOperationWrapperConstants.h"

@interface JADownloadWrapperBoxCom ()
@property (nonatomic,strong) BoxFilesRequestBuilder *requestBuilder;
@end

@implementation JADownloadWrapperBoxCom
@synthesize requestBuilder;

-(void)download {
    if (!requestBuilder) {
        self.requestBuilder = [[BoxFilesRequestBuilder alloc]init];
    }
    NSString *fileID = [self.pathsDictionary objectForKey:JAFileDownloadRemotePathKey];
    NSString *localPath = [self.pathsDictionary objectForKey:JAFileDownloadLocalPathKey];
    NSString *fileName = [self.pathsDictionary objectForKey:JAFileDownloadNameKey];
    NSString *fileOutputPath = [localPath stringByAppendingPathComponent:fileName];
    NSOutputStream *output = [NSOutputStream outputStreamToFileAtPath:fileOutputPath append:NO];

    [[BoxSDK sharedSDK].filesManager downloadFileWithID:fileID outputStream:output requestBuilder:nil success:^(NSString *fileID, long long expectedTotalBytes){
        NSDate *now = [NSDate date];
        [self.pathsDictionary setObject:now forKey:JAFileDownloadDateKey];
        self.completedBlock(self.pathsDictionary);
        
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
        self.failedBlock(error);
    } progress:^(long long expectedTotalBytes, unsigned long long bytesReceived)
    {
        CGFloat percent = bytesReceived/expectedTotalBytes;
        NSNumber *perc = [NSNumber numberWithFloat:percent];
        [self.pathsDictionary setObject:perc forKey:JAFileDownloadPercentageKey];
        self.progressBlock(self.pathsDictionary);
    }];
}

@end
