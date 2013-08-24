//
//  JAFileSystemDropbox.h
//  DataDeposit2
//
//  Created by JUSTIN AMBERSON on 8/24/13.
//  Copyright (c) 2013 justinxxvii. All rights reserved.
//

#import "JAFileSystem.h"
#import <DropboxSDK/DropboxSDK.h>

@interface JAFileSystemDropbox : JAFileSystem <DBRestClientDelegate>
@property (nonatomic,strong) DBRestClient *dbClient;
@end
