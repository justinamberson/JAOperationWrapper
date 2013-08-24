//
//  JAFileSystem.m
//  DataDeposit2
//
//  Created by JUSTIN AMBERSON on 8/24/13.
//  Copyright (c) 2013 justinxxvii. All rights reserved.
//

#import "JAFileSystem.h"
@interface JAFileSystem ()
-(id)initWithPathComponents:(NSArray *)pathComponents
             completedBlock:(JAFileSystemCompletedBlock)completedBlock
                failedBlock:(JAFileSystemFailedBlock)failBlock;
-(void)fetch;
@end

@implementation JAFileSystem
@synthesize completionBlock;
@synthesize failedBlock;
@synthesize pathComponents;

-(id) initWithPathComponents:(NSArray *)components
              completedBlock:(JAFileSystemCompletedBlock)completedBlock
                 failedBlock:(JAFileSystemFailedBlock)failBlock {
    if (self = [super init]) {
        self.completionBlock = completedBlock;
        self.failedBlock = failBlock;
        self.pathComponents = components;
    }
    return self;
}

+(void)getFileSystemForPathComponents:(NSArray *)pathComponents
                          completed:(JAFileSystemCompletedBlock)completedBlock
                             failed:(JAFileSystemFailedBlock)failed {
    id class = [[[self class] alloc] initWithPathComponents:pathComponents
                                             completedBlock:completedBlock
                                                failedBlock:failed];
    [class fetch];
    
}

-(void)fetch {
    NSLog(@"You should override this method in your subclass");
}

@end
