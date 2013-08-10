
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
 JABoxComUploadWrapper.h
 */

#import <Foundation/Foundation.h>
#import <BoxSDK/BoxSDK.h>

typedef void (^JABoxComUploadCompletedBlock)(NSMutableDictionary *uploadInfo);
typedef void (^JABoxComUploadFailedBlock)(NSError *error);
typedef void (^JABoxComUploadProgressBlock)(NSMutableDictionary *uploadInfo);

@interface JABoxComUploadWrapper : NSObject

/*
 NSMutableDictionary *pathsDictionary - should contain objects with these keys:
 NSString *const JAFileUploadNameKey
 NSString *const JAFileUploadRemotePathKey - Supply the "parent ID" here. See box.com documentation
 NSString *const JAFileUploadPathIDKey
 NSString *const JAFileUploadLocalPathKey */
@property (nonatomic,strong) NSMutableDictionary *pathsDictionary;

/*
 Gets set automatically  */
@property (nonatomic,assign,readonly) BOOL isUploading;

/*
 A block to fire upon new progress %, completion, or failure */
@property (nonatomic,copy) JABoxComUploadProgressBlock progressBlock; //receives NSDictionary
@property (nonatomic,copy) JABoxComUploadCompletedBlock completedBlock; //receives NSDictionary
@property (nonatomic,copy) JABoxComUploadFailedBlock failedBlock; //receives NSError

/*
 Main constructor to use to set up a new uploader
 JABoxComUploadWrapper *uploader = [JABoxComUploadWrapper uploaderWithPaths:... */
+(JABoxComUploadWrapper *)uploaderWithPaths:(NSMutableDictionary *)paths progress:(JABoxComUploadProgressBlock)progBlock completed:(JABoxComUploadCompletedBlock)compBlock failed:(JABoxComUploadFailedBlock)failBlock;

/*
 Begin upload work
 example:
 JABoxComUploadWrapper *uploader = [JABoxComUploadWrapper uploaderWithPaths:...
 [uploader upload]; */
-(void)upload;

@property (nonatomic,strong,readonly) BoxAPIMultipartToJSONOperation *boxUploadOperation;

@end
