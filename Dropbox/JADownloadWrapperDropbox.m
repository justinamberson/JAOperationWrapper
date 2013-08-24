//
//  JADownloadWrapperDropbox.m
//  DataDeposit2
//
//  Created by JUSTIN AMBERSON on 8/23/13.
//  Copyright (c) 2013 justinxxvii. All rights reserved.
//

#import "JADownloadWrapperDropbox.h"
#import "JAOperationWrapperConstants.h"

@interface JADownloadWrapperDropbox ()

@end

@implementation JADownloadWrapperDropbox

-(void)download {
    
    self.dbClient = [[DBRestClient alloc]initWithSession:[DBSession sharedSession]];
    _dbClient.delegate = self;
    
    NSString *fullRemotePath = [self.pathsDictionary objectForKey:JAFileDownloadRemotePathKey];
    NSString *localPath = [self.pathsDictionary objectForKey:JAFileDownloadLocalPathKey];
    NSString *fileName = [self.pathsDictionary objectForKey:JAFileDownloadNameKey];
    NSString *localFilePath = [localPath stringByAppendingPathComponent:fileName];
    [self.dbClient loadFile:fullRemotePath intoPath:localFilePath];
    
    NSLog(@"Attemtping Download");
    
}

-(void)cancelDownload {
    [self.dbClient cancelAllRequests];
}

#pragma mark DBRestClientDelegate

-(void)restClient:(DBRestClient *)client loadProgress:(CGFloat)progress forFile:(NSString *)destPath {
    NSLog(@"Progress...");
    [self.pathsDictionary setObject:[NSNumber numberWithFloat:progress] forKey:JAFileDownloadPercentageKey];
    self.progressBlock(self.pathsDictionary);
}

-(void)restClient:(DBRestClient *)client loadFileFailedWithError:(NSError *)error {
    NSLog(@"Error...");
    self.failedBlock(error);
}

-(void)restClient:(DBRestClient *)client loadedFile:(NSString *)destPath {
    NSLog(@"Finished...");
    NSDate *now = [NSDate date];
    [self.pathsDictionary setObject:now forKey:JAFileDownloadDateKey];
    [self.pathsDictionary setObject:@"Dropbox" forKey:JAFileDownloadServiceNameKey];
    self.completedBlock(self.pathsDictionary);
}

-(void)dealloc {
    NSLog(@"DropboxDownloader Dealloc");
}

@end
