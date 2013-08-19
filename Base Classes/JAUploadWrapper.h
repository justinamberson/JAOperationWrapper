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
 JAUploadWrapper.h
 */

#import <Foundation/Foundation.h>
#import "JAOperationWrapperConstants.h"

typedef void (^JAUploadProgressBlock)(NSMutableDictionary *uploadInfo);
typedef void (^JAUploadCompletedBlock)(NSMutableDictionary *uploadInfo);
typedef void (^JAUploadFailedBlock)(NSError *error);

@interface JAUploadWrapper : NSObject 

/*
 NSMutableDictionary *pathsDictionary - should contain objects with these keys:
 NSString *const JAFileUploadNameKey
 NSString *const JAFileUploadRemotePathKey - Array of NSStrings representing folder heirarchy
 NSString *const JAFileUploadPathIDKey
 NSString *const JAFileUploadLocalPathKey */
@property (nonatomic,strong) NSMutableDictionary *pathsDictionary;

/*
 Gets set automatically  */
@property (nonatomic,assign,readonly) BOOL isUploading;

/*
 A block to fire upon new progress %, completion, or failure */
@property (nonatomic,copy) JAUploadProgressBlock progressBlock; //receives pathsDictionary
@property (nonatomic,copy) JAUploadCompletedBlock completedBlock; //receives pathsDictionary
@property (nonatomic,copy) JAUploadFailedBlock failedBlock; //receives NSError

/*
 Main constructor to use to set up a new uploader
 JAFileUploadWrapper *uploader = [JAFileUploader uploaderWithPaths:...
 */
+(id)uploaderWithPaths:(NSMutableDictionary *)paths progress:(JAUploadProgressBlock)progBlock completed:(JAUploadCompletedBlock)compBlock failed:(JAUploadFailedBlock)failBlock;

/*
 Begin upload work
 example:
 JAUploadWrapper *uploader = [JAUploadWrapper uploaderWithPaths:...
 [uploader upload]; */
-(void)upload;

/*
 Cancel current upload
 Subclasses should override
 */
-(void)cancelUpload;


@end
