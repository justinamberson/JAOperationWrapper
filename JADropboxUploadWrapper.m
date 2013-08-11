
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

@end

@implementation JADropboxUploadWrapper

#pragma mark -
#pragma mark work

-(void)upload {
    
    if (!self.dbClient) {
        self.dbClient = [[DBRestClient alloc]initWithSession:[DBSession sharedSession]];
        _dbClient.delegate = self;
    }
    NSString *fileName = [self.pathsDictionary objectForKey:JAFileUploadNameKey];
    NSString *remotePath = [self.pathsDictionary objectForKey:JAFileUploadRemotePathKey];
    NSString *parentRev = [self.pathsDictionary objectForKey:JAFileUploadPathIDKey];
    NSString *localPath = [self.pathsDictionary objectForKey:JAFileUploadLocalPathKey];
    [_dbClient uploadFile:fileName toPath:remotePath withParentRev:parentRev fromPath:localPath];
    
}

#pragma mark -
#pragma mark DBRestClientDelegate

- (void)restClient:(DBRestClient*)client uploadedFile:(NSString*)destPath from:(NSString*)srcPath {
    NSDate *now = [NSDate date];
    [self.pathsDictionary setObject:now forKey:JAFileUploadDateKey];
    [self.pathsDictionary setObject:@"Dropbox" forKey:JAFileUploadServiceNameKey];
    self.completedBlock(self.pathsDictionary);
    
}
- (void)restClient:(DBRestClient*)client uploadProgress:(CGFloat)progress forFile:(NSString*)destPath from:(NSString*)srcPath {
    [self.pathsDictionary setObject:[NSNumber numberWithFloat:progress] forKey:JAFileUploadPercentageKey];
    self.progressBlock(self.pathsDictionary);
	
}
- (void)restClient:(DBRestClient*)client uploadFileFailedWithError:(NSError*)error {
    self.failedBlock(error);

}


@end
