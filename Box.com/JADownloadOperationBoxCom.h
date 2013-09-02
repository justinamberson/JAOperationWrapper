//
//  JADownloadOperationBoxCom.h
//  DataDeposit2
//
//  Created by JUSTIN AMBERSON on 8/25/13.
//  Copyright (c) 2013 justinxxvii. All rights reserved.
//

#import "JADownloadOperation.h"
#import "JADownloadWrapperBoxCom.h"

@interface JADownloadOperationBoxCom : JADownloadOperation
@property (nonatomic,strong) JADownloadWrapperBoxCom *downloader;
@end
