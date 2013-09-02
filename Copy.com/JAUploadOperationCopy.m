//
//  JAUploadOperationCopy.m
//  DataDeposit2
//
//  Created by JUSTIN AMBERSON on 9/2/13.
//  Copyright (c) 2013 justinxxvii. All rights reserved.
//

#import "JAUploadOperationCopy.h"

@implementation JAUploadOperationCopy

-(void)start {
    if (![NSThread mainThread]) {
        [self performSelectorOnMainThread:@selector(start) withObject:nil waitUntilDone:NO];
    }
    UIApplication *app = [UIApplication sharedApplication];
    [app setIdleTimerDisabled:YES];
    UIBackgroundTaskIdentifier bgTask = 0;
    bgTask = [app beginBackgroundTaskWithExpirationHandler:^
              {
                  [app endBackgroundTask:bgTask];
                  
              }];

    if (!self.uploadWrapper) {
        self.uploadWrapper = [JAUploadWrapperCopy uploaderWithPaths:self.itemToUpload progress:^(NSMutableDictionary *uploadInfo) {
            if (self.isCancelled) {
                [self.uploadWrapper cancelUpload];
                [self updateCompletedState];
                [app endBackgroundTask:bgTask];
            }
            if ([self.operationDelegate respondsToSelector:@selector(uploadOperation:didUploadPercentageForItem:)]) {
                [self.operationDelegate uploadOperation:self didUploadPercentageForItem:uploadInfo];
            }
            
        } completed:^(NSMutableDictionary *uploadInfo) {
            
            if ([self.operationDelegate respondsToSelector:@selector(uploadOperation:uploadedLocalFileWithInfo:)]) {
                [self.operationDelegate uploadOperation:self uploadedLocalFileWithInfo:uploadInfo];
            }
            [app endBackgroundTask:bgTask];
            
        } failed:^(NSError *error) {
            
            if ([self.operationDelegate respondsToSelector:@selector(uploadOperation:uploadFailedWithError:)]) {
                [self.operationDelegate uploadOperation:self uploadFailedWithError:error];
            }
            [app endBackgroundTask:bgTask];
            
        }];
    }
    [self.uploadWrapper upload];
}

@end
