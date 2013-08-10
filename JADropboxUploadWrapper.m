
/*
 The MIT License (MIT)
 
 Copyright (c) 2013 Justin Amberson
 
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.
 */

/*
 JADropboxUploadWrapper.m
 */

#import "JADropboxUploadWrapper.h"
@interface JADropboxUploadWrapper ()

-(id)initWithPaths:(NSMutableDictionary *)paths progress:(JADropboxUploadProgressBlock)progBlock completed:(JADropboxUploadCompletedBlock)compBlock failed:(JADropboxUploadFailedBlock)failBlock;
@end

@implementation JADropboxUploadWrapper

#pragma mark -
#pragma mark object init methods

-(id)initWithPaths:(NSMutableDictionary *)paths progress:(JADropboxUploadProgressBlock)progBlock completed:(JADropboxUploadCompletedBlock)compBlock failed:(JADropboxUploadFailedBlock)failBlock {
    if (self = [super init]) {
        _dbClient = [[DBRestClient alloc]initWithSession:[DBSession sharedSession]];
        _dbClient.delegate = self;
        self.pathsDictionary = paths;
        _failedBlock = failBlock;
        _completedBlock = compBlock;
        _progressBlock = progBlock;
    }
    return self;
    
}

+(JADropboxUploadWrapper *)uploaderWithPaths:(NSMutableDictionary *)paths progress:(JADropboxUploadProgressBlock)progBlock completed:(JADropboxUploadCompletedBlock)compBlock failed:(JADropboxUploadFailedBlock)failBlock {
   return [[JADropboxUploadWrapper alloc]initWithPaths:paths progress:progBlock completed:compBlock failed:failBlock];
}

#pragma mark -
#pragma mark work

-(void)upload {
    _isUploading = YES;
    NSString *fileName = [_pathsDictionary objectForKey:JAFileUploadNameKey];
    NSString *remotePath = [_pathsDictionary objectForKey:JAFileUploadRemotePathKey];
    NSString *parentRev = [_pathsDictionary objectForKey:JAFileUploadPathIDKey];
    NSString *localPath = [_pathsDictionary objectForKey:JAFileUploadLocalPathKey];
    [_dbClient uploadFile:fileName toPath:remotePath withParentRev:parentRev fromPath:localPath];
}

#pragma mark -
#pragma mark DBRestClientDelegate

- (void)restClient:(DBRestClient*)client uploadedFile:(NSString*)destPath from:(NSString*)srcPath {
    NSDate *now = [NSDate date];
    [_pathsDictionary setObject:now forKey:JAFileUploadDateKey];
    [_pathsDictionary setObject:@"Dropbox" forKey:JAFileUploadServiceNameKey];
    _completedBlock(_pathsDictionary);
    _isUploading = NO;
    
}
- (void)restClient:(DBRestClient*)client uploadProgress:(CGFloat)progress forFile:(NSString*)destPath from:(NSString*)srcPath {
    [_pathsDictionary setObject:[NSNumber numberWithFloat:progress] forKey:JAFileUploadPercentageKey];
    _progressBlock(_pathsDictionary);
	
}
- (void)restClient:(DBRestClient*)client uploadFileFailedWithError:(NSError*)error {
    _failedBlock(error);
    _isUploading = NO;

	
}


@end
