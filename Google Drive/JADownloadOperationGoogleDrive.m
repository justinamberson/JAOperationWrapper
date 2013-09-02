//
//  JADownloadOperationGoogleDrive.m
//  DataDeposit2
//
//  Created by JUSTIN AMBERSON on 8/25/13.
//  Copyright (c) 2013 justinxxvii. All rights reserved.
//

#import "JADownloadOperationGoogleDrive.h"
#import "JADownloadWrapperGoogleDrive.h"
@interface JADownloadWrapperGoogleDrive ()

@end

@implementation JADownloadOperationGoogleDrive
@synthesize downloader;

-(void)start {
    if (![NSThread isMainThread]) {
        [self performSelectorOnMainThread:@selector(start) withObject:nil waitUntilDone:NO];
        return;
    }
    UIApplication *app = [UIApplication sharedApplication];
    [app setIdleTimerDisabled:YES];
    UIBackgroundTaskIdentifier bgTask = 0;
    bgTask = [app beginBackgroundTaskWithExpirationHandler:^
              {
                  [app endBackgroundTask:bgTask];
                  
              }];

    if (!self.downloader) {
        self.downloader = [JADownloadWrapperGoogleDrive downloaderWithPaths:self.itemToDownload progress:^(NSMutableDictionary *uploadInfo) {
            if ([self.operationDelegate respondsToSelector:@selector(downloadOperation:didDownloadPercentageForItem:)]) {
                [self.operationDelegate downloadOperation:self didDownloadPercentageForItem:uploadInfo];
                if (self.isCancelled) {
                    [app endBackgroundTask:bgTask];
                }
            }
        } completed:^(NSMutableDictionary *uploadInfo) {
            if ([self.operationDelegate respondsToSelector:@selector(downloadOperation:downloadedLocalFileWithInfo:)]) {
                [self.operationDelegate downloadOperation:self downloadedLocalFileWithInfo:uploadInfo];
                [app endBackgroundTask:bgTask];
            }
        } failed:^(NSError *error) {
            if ([self.operationDelegate respondsToSelector:@selector(downloadOperation:downloadFailedWithError:)]) {
                [self.operationDelegate downloadOperation:self downloadFailedWithError:error];
                [app endBackgroundTask:bgTask];
            }
        }];
    }
    [downloader download];
}
@end
