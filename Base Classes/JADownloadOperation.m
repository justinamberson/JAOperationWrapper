//
//  JADownloadOperation.m
//  DataDeposit2
//
//  Created by JUSTIN AMBERSON on 8/23/13.
//  Copyright (c) 2013 justinxxvii. All rights reserved.
//

#import "JADownloadOperation.h"
@interface JADownloadOperation ()
@property (nonatomic,assign, readonly) BOOL executing;
@property (nonatomic,assign, readonly) BOOL finished;
@end

@implementation JADownloadOperation

-(id)initWithDownloadInfo:(NSMutableDictionary *)info {
    if (self = [super init]) {
        self.itemToDownload = info;
        _finished = NO;
        _executing = NO;
    }
    return self;
}

- (BOOL)isConcurrent { return YES; }

- (BOOL)isExecuting { return _executing; }

- (BOOL)isFinished { return _finished; }

- (void)updateCompletedState {
    [self willChangeValueForKey:@"isExecuting"];
    _executing = NO;
    [self didChangeValueForKey:@"isExecuting"];
	
    [self willChangeValueForKey:@"isFinished"];
    _finished = YES;
    [self didChangeValueForKey:@"isFinished"];
}

@end
