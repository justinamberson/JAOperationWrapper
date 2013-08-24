//
//  JADownloadOperationDropbox.h
//  DataDeposit2
//
//  Created by JUSTIN AMBERSON on 8/23/13.
//  Copyright (c) 2013 justinxxvii. All rights reserved.
//

#import "JADownloadOperation.h"
#import "JADownloadWrapperDropbox.h"

@interface JADownloadOperationDropbox : JADownloadOperation

@property (nonatomic,strong) JADownloadWrapperDropbox *downloadWrapper;

@end
