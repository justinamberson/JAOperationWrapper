
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
 JADropboxUploadWrapper.h
 */
#import <Foundation/Foundation.h>
#import <DropboxSDK/DBRestClient.h>
#import "JAOperationWrapperConstants.h"

typedef void (^JADropboxUploadProgressBlock)(NSMutableDictionary *uploadInfo);
typedef void (^JADropboxUploadCompletedBlock)(NSMutableDictionary *uploadInfo);
typedef void (^JADropboxUploadFailedBlock)(NSError *error);

@interface JADropboxUploadWrapper : NSObject <DBRestClientDelegate>

/*
 NSMutableDictionary *pathsDictionary - should contain objects with these keys:
 NSString *const JAFileUploadNameKey
 NSString *const JAFileUploadRemotePathKey
 NSString *const JAFileUploadPathIDKey
 NSString *const JAFileUploadLocalPathKey */
@property (nonatomic,strong) NSMutableDictionary *pathsDictionary;

/*
 Gets set automatically  */
@property (nonatomic,assign,readonly) BOOL isUploading;

/*
 A block to fire upon new progress %, completion, or failure */
@property (nonatomic,copy) JADropboxUploadProgressBlock progressBlock; //receives pathsDictionary
@property (nonatomic,copy) JADropboxUploadCompletedBlock completedBlock; //receives pathsDictionary
@property (nonatomic,copy) JADropboxUploadFailedBlock failedBlock; //receives NSError

/*
 Main constructor to use to set up a new uploader
 JADropboxFileUploadWrapper *uploader = [JADropboxFileUploader uploaderWithPaths:... 
 */
+(JADropboxUploadWrapper *)uploaderWithPaths:(NSMutableDictionary *)paths progress:(JADropboxUploadProgressBlock)progBlock completed:(JADropboxUploadCompletedBlock)compBlock failed:(JADropboxUploadFailedBlock)failBlock;

/*
 Begin upload work
 example:
 JADropboxFileUploadWrapper *uploader = [JADropboxUploadWrapper uploaderWithPaths:...
 [uploader upload]; */
-(void)upload;

@property (nonatomic,strong,readonly) DBRestClient *dbClient;

@end
