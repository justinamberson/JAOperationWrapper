//
//  JAUploadWrapperCopy.m
//  DataDeposit2
//
//  Created by JUSTIN AMBERSON on 9/2/13.
//  Copyright (c) 2013 justinxxvii. All rights reserved.
//

#import "JAUploadWrapperCopy.h"
#import "CopySDK.h"
@interface JAUploadWrapperCopy ()
@property (nonatomic,strong) COCopyClient *theCopyClient;
@end
@implementation JAUploadWrapperCopy

-(void)upload {
    NSLog(@"Copy Upload");
    if (!self.theCopyClient) {
        self.theCopyClient = [[COCopyClient alloc]initWithToken:CopyOAuthToken() andTokenSecret:CopyOAuthSecret()];
    }
    NSString *localPath = [self.pathsDictionary objectForKey:JAFileUploadLocalPathKey];
    NSString *fileName = [self.pathsDictionary objectForKey:JAFileUploadNameKey];
    NSLog(@"Local path: %@",localPath);
    NSArray *remotePaths = [self.pathsDictionary objectForKey:JAFileUploadRemotePathKey];
    NSMutableString *pathString = [NSMutableString string];
    [pathString appendString:@"/"];
    for (NSString *path in remotePaths) {
        [pathString appendString:path];
        [pathString appendString:@"/"];
        if ([[remotePaths lastObject] isEqual:path]) {
            [pathString appendString:fileName];
        }
    }
    NSLog(@"Remote path: %@",pathString);
    [self.theCopyClient cancellableUploadFromFilePath:localPath toRemotePath:pathString withProgressBlock:^(long long uploadedSoFar, long long contentLength) {
        CGFloat uploadPerc = (CGFloat)uploadedSoFar/(CGFloat)contentLength;
        NSNumber *percNum = [NSNumber numberWithFloat:uploadPerc];
        [self.pathsDictionary setObject:percNum forKey:JAFileUploadPercentageKey];
        self.progressBlock(self.pathsDictionary);
    } andCompletionBlock:^(BOOL success, NSError *error, NSDictionary *fileInfo) {
        if (!error) {
            NSLog(@"Copy.com file info: %@",fileInfo);
            [self.pathsDictionary setObject:[NSDate date] forKey:JAFileUploadDateKey];
            [self.pathsDictionary setObject:@"Copy.com" forKey:JAFileUploadServiceNameKey];
            self.completedBlock(self.pathsDictionary);
        } else {
            NSLog(@"Copy.com upload error: %@",error);
            self.failedBlock(error);
        }
    }];
}

-(void)cancelUpload {
    [self.theCopyClient cancelCurrentUpload];
}

@end
