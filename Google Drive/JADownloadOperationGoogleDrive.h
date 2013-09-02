//
//  JADownloadOperationGoogleDrive.h
//  DataDeposit2
//
//  Created by JUSTIN AMBERSON on 8/25/13.
//  Copyright (c) 2013 justinxxvii. All rights reserved.
//

#import "JADownloadOperation.h"
#import "JADownloadWrapperGoogleDrive.h"

@interface JADownloadOperationGoogleDrive : JADownloadOperation
@property (nonatomic,strong) JADownloadWrapperGoogleDrive *downloader;
@end
