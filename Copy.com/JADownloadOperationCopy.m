//
//  JADownloadOperationCopy.m
//  DataDeposit2
//
//  Created by JUSTIN AMBERSON on 9/2/13.
//  Copyright (c) 2013 justinxxvii. All rights reserved.
//

#import "JADownloadOperationCopy.h"
#import "JADownloadWrapperCopy.h"
#import "JAOperationWrapperConstants.h"

@interface JADownloadOperationCopy ()
@property (nonatomic,strong) JADownloadWrapperCopy *downloadWrapper;
@end

@implementation JADownloadOperationCopy

-(void)start {
    if (![NSThread isMainThread]) {
        [self performSelectorOnMainThread:@selector(start) withObject:nil waitUntilDone:NO];
    }
    if (!self.downloadWrapper) {
        self.downloadWrapper = [JADownloadWrapperCopy downloaderWithPaths:self.itemToDownload progress:^(NSMutableDictionary *uploadInfo) {
            if ([self.operationDelegate respondsToSelector:@selector(downloadOperation:didDownloadPercentageForItem:)]) {
                [self.operationDelegate downloadOperation:self didDownloadPercentageForItem:uploadInfo];
            }
        } completed:^(NSMutableDictionary *uploadInfo) {
            if ([self.operationDelegate respondsToSelector:@selector(downloadOperation:downloadedLocalFileWithInfo:)]) {
                [self.operationDelegate downloadOperation:self downloadedLocalFileWithInfo:uploadInfo];
            }
        } failed:^(NSError *error) {
            if ([self.operationDelegate respondsToSelector:@selector(downloadOperation:downloadFailedWithError:)]) {
                [self.operationDelegate downloadOperation:self downloadFailedWithError:error];
            }
        }];
    }
    [self.downloadWrapper download];
}

@end
