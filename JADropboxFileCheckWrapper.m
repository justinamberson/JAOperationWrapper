
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
@property (nonatomic,strong) DBRestClient *dbClient;
-(id)initWithPaths:(NSMutableDictionary *)paths completed:(JADropboxCheckerCompletedBlock)compBlock failed:(JADropboxCheckerFailedBlock)failBlock;
@end

@implementation JADropboxFileCheckWrapper

-(id)initWithPaths:(NSMutableDictionary *)paths completed:(JADropboxCheckerCompletedBlock)compBlock failed:(JADropboxCheckerFailedBlock)failBlock {
	if (self = [super init]) {
		self.dbClient = [[DBRestClient alloc] initWithSession:[DBSession sharedSession]];
		self.dbClient.delegate = self;
        self.pathsDictionary = paths;
        _completedBlock = compBlock;
        _failedBlock = failBlock;
	}
	return self;
}

+(JADropboxFileCheckWrapper *)checkerWithPaths:(NSMutableDictionary *)paths completed:(JADropboxCheckerCompletedBlock)compBlock failed:(JADropboxCheckerFailedBlock)failBlock {
    return [[JADropboxFileCheckWrapper alloc] initWithPaths:paths completed:compBlock failed:failBlock];
}


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
    _completedBlock(_pathsDictionary);
    _isChecking = NO;
    
    
}


- (void)restClient:(DBRestClient*)client loadMetadataFailedWithError:(NSError*)error {
    
    if (error.code == 404) {
        //Run the completed block. Dropbox is complaining that the remotePath doesn't exist.
        //When you attempt to upload to this path, it will be created if it does not exist.
        //So, don't worry about it if you encounter 404
        _completedBlock(_pathsDictionary);
    } else {
        //other errors, tell client
        _failedBlock(error);
    }
    
    _isChecking = NO;
}

-(void)checkFile {
    NSString *remotePath = [self.pathsDictionary objectForKey:JAFileUploadRemotePathKey];
    _isChecking = YES;
    [self.dbClient loadMetadata:remotePath];
}


@end
