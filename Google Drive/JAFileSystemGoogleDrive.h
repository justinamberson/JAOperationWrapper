//
//  JAFileSystemGoogleDrive.h
//  DataDeposit2
//
//  Created by JUSTIN AMBERSON on 8/25/13.
//  Copyright (c) 2013 justinxxvii. All rights reserved.
//

#import "JAFileSystem.h"
#import "GTLDrive.h"

@interface JAFileSystemGoogleDrive : JAFileSystem
@property (nonatomic,strong) GTLServiceDrive *service;

@end
