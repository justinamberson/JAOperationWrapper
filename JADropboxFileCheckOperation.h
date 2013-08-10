
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
 JADropboxFileCheckOperation.h
 */

#import <Foundation/Foundation.h>
#import "JADropboxFileCheckWrapper.h"

@class JADropboxFileCheckOperation;

@protocol JADropboxFileCheckOperationDelegate <NSObject>

-(void)dropboxOperation:(JADropboxFileCheckOperation *)operation checkFailedWithError:(NSError *)error;
-(void)dropboxOperation:(JADropboxFileCheckOperation *)operation checkFinishedWithInfo:(NSMutableDictionary *)infoDict;

@end

@interface JADropboxFileCheckOperation : NSOperation

/*
 NSMutableDictionary *itemToUpload - should contain objects with these keys:
 NSString *const JAFileUploadNameKey
 NSString *const JAFileUploadRemotePathKey
 NSString *const JAFileUploadLocalPathKey */
@property (nonatomic,strong) NSMutableDictionary *itemToUpload;

/*
 To receive the delegate callbacks checkFailedWithError, checkFinishedWithInfo */
@property (nonatomic,weak) id<JADropboxFileCheckOperationDelegate> operationDelegate;

/*
 Constructor method */
-(id)initWithUploadInfo:(NSMutableDictionary *)uploadInfo;

/*
 Call this when the operation is finished */
-(void)updateCompletedState;


@end
