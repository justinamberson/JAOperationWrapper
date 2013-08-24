//
//  JADownloadWrapperDropbox.h
//  DataDeposit2
//
//  Created by JUSTIN AMBERSON on 8/23/13.
//  Copyright (c) 2013 justinxxvii. All rights reserved.
//

#import "JADownloadWrapper.h"
#import <DropboxSDK/DropboxSDK.h>

@interface JADownloadWrapperDropbox : JADownloadWrapper <DBRestClientDelegate>
@property (nonatomic,strong) DBRestClient *dbClient;
@end
