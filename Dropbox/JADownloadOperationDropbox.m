//
//  JADownloadOperationDropbox.m
//  DataDeposit2
//
//  Created by JUSTIN AMBERSON on 8/23/13.
//  Copyright (c) 2013 justinxxvii. All rights reserved.
//

#import "JADownloadOperationDropbox.h"

@implementation JADownloadOperationDropbox
@synthesize downloadWrapper;

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
    self.downloadWrapper = [JADownloadWrapperDropbox downloaderWithPaths:self.itemToDownload progress:^(NSMutableDictionary *downloadInfo) {
        if (self.isCancelled) {
            [self.downloadWrapper cancelDownload];
            [self updateCompletedState];
            [app endBackgroundTask:bgTask];
        }
        if ([self.operationDelegate respondsToSelector:@selector(downloadOperation:didDownloadPercentageForItem:)]) {
            [self.operationDelegate downloadOperation:self didDownloadPercentageForItem:downloadInfo];
        }
        
    } completed:^(NSMutableDictionary *info) {
        if ([self.operationDelegate respondsToSelector:@selector(downloadOperation:downloadedLocalFileWithInfo:)]) {
            [self.operationDelegate downloadOperation:self downloadedLocalFileWithInfo:info];
        }
        [app endBackgroundTask:bgTask];
        
    } failed:^(NSError *error) {
        if ([self.operationDelegate respondsToSelector:@selector(downloadOperation:downloadFailedWithError:)]) {
            [self.operationDelegate downloadOperation:self downloadFailedWithError:error];
        }
        
        [app endBackgroundTask:bgTask];
    }];
    [self.downloadWrapper download];
    
    
}


@end
