//
//  JAFileSystem.h
//  DataDeposit2
//
//  Created by JUSTIN AMBERSON on 8/24/13.
//  Copyright (c) 2013 justinxxvii. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^JAFileSystemCompletedBlock)(NSMutableArray *remoteFiles);
typedef void (^JAFileSystemFailedBlock)(NSError *error);

@interface JAFileSystem : NSObject

+(id)getFileSystemForPathComponents:(NSArray *)pathComponents
                          completed:(JAFileSystemCompletedBlock)completedBlock
                             failed:(JAFileSystemFailedBlock)failed;

@property (nonatomic,copy) JAFileSystemCompletedBlock completionBlock;
@property (nonatomic,copy) JAFileSystemFailedBlock failedBlock;
@property (nonatomic,copy) NSArray *pathComponents;

-(void)fetch;

@end
