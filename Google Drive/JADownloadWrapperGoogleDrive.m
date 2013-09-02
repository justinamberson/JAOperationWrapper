//
//  JADownloadWrapperGoogleDrive.m
//  DataDeposit2
//
//  Created by JUSTIN AMBERSON on 8/25/13.
//  Copyright (c) 2013 justinxxvii. All rights reserved.
//

#import "JADownloadWrapperGoogleDrive.h"
#import "GTLDrive.h"
#import "GTMOAuth2ViewControllerTouch.h"
#import "JAOperationWrapperConstants.h"

@interface JADownloadWrapperGoogleDrive ()
@property (nonatomic,strong) GTLServiceDrive *service;
@property (nonatomic,strong) GTMHTTPFetcher *fetcher;
@end

@implementation JADownloadWrapperGoogleDrive
@synthesize service;
@synthesize fetcher;

-(void)download {
    if (!self.service) {
        self.service = [[GTLServiceDrive alloc]init];
        self.service.authorizer = Google_Authorizer();
        
    }
    
    NSString *localPath = [self.pathsDictionary objectForKey:JAFileDownloadLocalPathKey];
    NSString *fileName = [self.pathsDictionary objectForKey:JAFileDownloadNameKey];
    NSString *remotePath = [self.pathsDictionary objectForKey:JAFileDownloadRemotePathKey];
    NSString *pathToWrite = [localPath stringByAppendingPathComponent:fileName];
    GTLQueryDrive *query = [GTLQueryDrive queryForFilesGetWithFileId:remotePath];
    
    [self.service executeQuery:query completionHandler:^(GTLServiceTicket *ticket, id object, NSError *error) {
        if (!error) {
            GTLDriveFile *file = (GTLDriveFile *)object;
            NSString *downloadURL = file.downloadUrl;
            NSURL *fileURL = [NSURL URLWithString:downloadURL];
            NSURLRequest *request = [NSURLRequest requestWithURL:fileURL];
            self.fetcher = [GTMHTTPFetcher fetcherWithRequest:request];
            self.fetcher.authorizer = self.service.authorizer;
            [self.fetcher setReceivedDataBlock:^(NSData *data) {
                float percentTransfered = self.fetcher.downloadedLength * 100.0f / self.fetcher.response.expectedContentLength;
                NSNumber *perc = [NSNumber numberWithFloat:percentTransfered];
                [self.pathsDictionary setObject:perc forKey:JAFileDownloadPercentageKey];
                self.progressBlock(self.pathsDictionary);
                // Do something with progress
            }];
            [self.fetcher beginFetchWithCompletionHandler:^(NSData *data, NSError *error) {
                if (!error) {
                    if ([data writeToFile:pathToWrite atomically:YES]) {
                        NSDate *now = [NSDate date];
                        [self.pathsDictionary setObject:now forKey:JAFileDownloadDateKey];
                        [self.pathsDictionary setObject:[NSNumber numberWithFloat:1.00] forKey:JAFileDownloadPercentageKey];
                        [self.pathsDictionary setObject:@"Google Drive" forKey:JAFileDownloadServiceNameKey];
                        self.completedBlock(self.pathsDictionary);
                    } else {
                        self.failedBlock(nil);
                    }
                } else {
                    self.failedBlock(error);
                }
            }];
            
        } else {
            self.failedBlock(error);
        }
    }];
    


}


@end
