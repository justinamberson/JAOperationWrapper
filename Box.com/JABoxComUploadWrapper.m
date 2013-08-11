
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

@end

@implementation JABoxComUploadWrapper

#pragma mark -
#pragma mark work

-(void)upload {
    NSString *localPath = [self.pathsDictionary objectForKey:JAFileUploadLocalPathKey];
    NSString *fileName = [self.pathsDictionary objectForKey:JAFileUploadNameKey];
    NSString *fileID = [self.pathsDictionary objectForKey:JAFileUploadPathIDKey];
    NSString *parentID = [self.pathsDictionary objectForKey:JAFileUploadRemotePathKey];
    BoxFileBlock fileBlock = ^(BoxFile *file)
    {
        NSString *pathID = [file.rawResponseJSON objectForKey:@"id"];
        [self.pathsDictionary setObject:pathID forKey:JAFileUploadPathIDKey];
        [self.pathsDictionary setObject:[NSDate date] forKey:JAFileUploadDateKey];
        [self.pathsDictionary setObject:@"Box.com" forKey:JAFileUploadServiceNameKey];
        self.completedBlock(self.pathsDictionary);
    };
    
    BoxAPIJSONFailureBlock failureBlock = ^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, NSDictionary *JSONDictionary)
    {
        self.failedBlock(error);
    };
    
    BoxAPIMultipartProgressBlock blockProgress = ^(unsigned long long totalBytes, unsigned long long bytesSent)
    {
        CGFloat prog = (float)bytesSent/(float)totalBytes;
        [self.pathsDictionary setObject:[NSNumber numberWithFloat:prog] forKey:JAFileUploadPercentageKey];
        self.progressBlock(self.pathsDictionary);
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

@end
