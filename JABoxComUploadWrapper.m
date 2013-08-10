
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
 JABoxComUploadWrapper.m
 */

#import "JABoxComUploadWrapper.h"
#import "JAOperationWrapperConstants.h"
@interface JABoxComUploadWrapper ()
@property (nonatomic,strong) BoxFilesRequestBuilder *requestBuilder;
-(id)initWithPaths:(NSMutableDictionary *)paths progress:(JABoxComUploadProgressBlock)progBlock completed:(JABoxComUploadCompletedBlock)compBlock failed:(JABoxComUploadFailedBlock)failBlock;
@end

@implementation JABoxComUploadWrapper

-(id)initWithPaths:(NSMutableDictionary *)paths progress:(JABoxComUploadProgressBlock)progBlock completed:(JABoxComUploadCompletedBlock)compBlock failed:(JABoxComUploadFailedBlock)failBlock {
    if (self = [super init]) {
        self.pathsDictionary = paths;
        _failedBlock = failBlock;
        _completedBlock = compBlock;
        _progressBlock = progBlock;
    }
    return self;
    
}

+(JABoxComUploadWrapper *)uploaderWithPaths:(NSMutableDictionary *)paths progress:(JABoxComUploadProgressBlock)progBlock completed:(JABoxComUploadCompletedBlock)compBlock failed:(JABoxComUploadFailedBlock)failBlock {
    return [[JABoxComUploadWrapper alloc]initWithPaths:paths progress:progBlock completed:compBlock failed:failBlock];
    
}

#pragma mark -
#pragma mark work

-(void)upload {
    _isUploading = YES;
    NSString *localPath = [_pathsDictionary objectForKey:JAFileUploadLocalPathKey];
    NSString *fileName = [_pathsDictionary objectForKey:JAFileUploadNameKey];
    NSString *fileID = [_pathsDictionary objectForKey:JAFileUploadPathIDKey];
    NSString *parentID = [_pathsDictionary objectForKey:JAFileUploadRemotePathKey];
    BoxFileBlock fileBlock = ^(BoxFile *file)
    {
        NSString *pathID = [file.rawResponseJSON objectForKey:@"id"];
        [_pathsDictionary setObject:pathID forKey:JAFileUploadPathIDKey];
        [_pathsDictionary setObject:[NSDate date] forKey:JAFileUploadDateKey];
        [_pathsDictionary setObject:@"BoxCom" forKey:JAFileUploadServiceNameKey];
        _completedBlock(_pathsDictionary);
        _isUploading = NO;
        
    };
    
    BoxAPIJSONFailureBlock failureBlock = ^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, NSDictionary *JSONDictionary)
    {
        _failedBlock(error);
        _isUploading = NO;
    };
    
    BoxAPIMultipartProgressBlock blockProgress = ^(unsigned long long totalBytes, unsigned long long bytesSent)
    {
        CGFloat prog = (float)bytesSent/(float)totalBytes;
        [_pathsDictionary setObject:[NSNumber numberWithFloat:prog] forKey:JAFileUploadPercentageKey];
        _progressBlock(_pathsDictionary);
    };

    BoxFilesRequestBuilder *builder = [[BoxFilesRequestBuilder alloc] init];
    builder.name = fileName;
    if (parentID) {
    	builder.parentID = parentID;
	} else {
		builder.parentID = BoxAPIFolderIDRoot;
    }
    NSInputStream *inputStream = [NSInputStream inputStreamWithFileAtPath:localPath];
    NSDictionary *fileAttributes = [[NSFileManager defaultManager] attributesOfItemAtPath:localPath error:nil];
    long long contentLength = [[fileAttributes objectForKey:NSFileSize] longLongValue];
    if (fileID) {
        _boxUploadOperation = [[BoxSDK sharedSDK].filesManager overwriteFileWithID:fileID inputStream:inputStream contentLength:contentLength MIMEType:nil requestBuilder:builder success:fileBlock failure:failureBlock progress:blockProgress];
    } else {
        _boxUploadOperation = [[BoxSDK sharedSDK].filesManager uploadFileWithInputStream:inputStream contentLength:contentLength MIMEType:nil requestBuilder:builder success:fileBlock failure:failureBlock progress:blockProgress];
    }
}

#pragma mark -
#pragma mark DBRestClientDelegate




@end
