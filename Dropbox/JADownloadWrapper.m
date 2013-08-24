//
//  JADownloadWrapper.m
//  DataDeposit2
//
//  Created by JUSTIN AMBERSON on 8/23/13.
//  Copyright (c) 2013 justinxxvii. All rights reserved.
//

#import "JADownloadWrapper.h"
@interface JADownloadWrapper ()

-(id)initWithPaths:(NSMutableDictionary *)paths progress:(JADownloadProgressBlock)progBlock completed:(JADownloadCompletedBlock)compBlock failed:(JADownloadFailedBlock)failBlock;
@end

@implementation JADownloadWrapper

#pragma mark -
#pragma mark object init methods

-(id)initWithPaths:(NSMutableDictionary *)paths progress:(JADownloadProgressBlock)progBlock completed:(JADownloadCompletedBlock)compBlock failed:(JADownloadFailedBlock)failBlock {
    if (self = [super init]) {
        self.pathsDictionary = paths;
        _failedBlock = failBlock;
        _completedBlock = compBlock;
        _progressBlock = progBlock;
    }
    return self;
}

+(id)downloaderWithPaths:(NSMutableDictionary *)paths progress:(JADownloadProgressBlock)progBlock completed:(JADownloadCompletedBlock)compBlock failed:(JADownloadFailedBlock)failBlock {
    return [[[self class] alloc]initWithPaths:paths progress:progBlock completed:compBlock failed:failBlock];
}

-(void)download {
    NSLog(@"You must override this method in your subclass. Perform needed setup here, wire up delegates, etc.");
}

-(void)cancelDownload {
    NSLog(@"You must override this method in your subclass. Kil the upload service in this method.");
}


@end
