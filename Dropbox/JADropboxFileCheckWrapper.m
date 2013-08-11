
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
 JADropboxFileCheckWrapper.m
 */

#import "JADropboxFileCheckWrapper.h"
@interface JADropboxFileCheckWrapper ()

@end

@implementation JADropboxFileCheckWrapper

-(void)checkFile {
    if (!self.dbClient) {
        self.dbClient = [[DBRestClient alloc]initWithSession:[DBSession sharedSession]];
        _dbClient.delegate = self;
    }
    NSString *remotePath = [self.pathsDictionary objectForKey:JAFileUploadRemotePathKey];
    [_dbClient loadMetadata:remotePath];
}

#pragma mark -
#pragma mark DBRestClientDelegate

- (void)restClient:(DBRestClient*)client loadedMetadata:(DBMetadata*)metadata {
    
	BOOL fileAvailable = NO;
	NSString *availableFilePath;
    NSString *parentRevision;
	for (DBMetadata *child in metadata.contents) {
		NSString *lastObject = [[child.path pathComponents]lastObject];
		NSString *filePath = child.path;
		if ([lastObject isEqualToString:[self.pathsDictionary objectForKey:JAFileUploadNameKey]]) {
			fileAvailable = YES;
			availableFilePath = filePath;
            parentRevision = child.rev;
		}
	}
	if (fileAvailable) {
        //File was found, record the Parent Revision
		[self.pathsDictionary setObject:parentRevision forKey:JAFileUploadPathIDKey];
	}
    self.completedBlock(self.pathsDictionary);
    
    
}

- (void)restClient:(DBRestClient*)client loadMetadataFailedWithError:(NSError*)error {
    
    if (error.code == 404) {
        //Run the completed block. Dropbox is complaining that the remotePath doesn't exist.
        //When you attempt to upload to this path, it will be created if it does not exist.
        //So, don't worry about it if you encounter 404
        self.completedBlock(self.pathsDictionary);
    } else {
        //other errors, tell client
        self.failedBlock(error);
    }
    
    
}

@end
