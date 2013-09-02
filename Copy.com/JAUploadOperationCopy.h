//
//  JAUploadOperationCopy.h
//  DataDeposit2
//
//  Created by JUSTIN AMBERSON on 9/2/13.
//  Copyright (c) 2013 justinxxvii. All rights reserved.
//

#import "JAUploadOperation.h"
#import "JAUploadWrapperCopy.h"
@interface JAUploadOperationCopy : JAUploadOperation
@property (nonatomic,strong) JAUploadWrapperCopy *uploadWrapper;
@end
