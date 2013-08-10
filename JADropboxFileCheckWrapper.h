
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
 JADropboxFileCheckWrapper.h
 */

#import <Foundation/Foundation.h>
#import <DropboxSDK/DropboxSDK.h>
#import "JAOperationWrapperConstants.h"

typedef void (^JADropboxCheckerCompletedBlock)(NSMutableDictionary *fileInfo);
typedef void (^JADropboxCheckerFailedBlock)(NSError *error);

@interface JADropboxFileCheckWrapper : NSObject <DBRestClientDelegate>

/*
 NSMutableDictionary *pathsDictionary - should contain objects with these keys:
 NSString *const JAFileUploadNameKey
 NSString *const JAFileUploadRemotePathKey */
@property (nonatomic,strong) NSMutableDictionary *pathsDictionary;

/*
 Gets set automatically  */
@property (nonatomic,assign,readonly) BOOL isChecking;

/*
 A block to fire upon completion, or failure */
@property (nonatomic,copy) JADropboxCheckerCompletedBlock completedBlock; //receives NSDictionary
@property (nonatomic,copy) JADropboxCheckerFailedBlock failedBlock; //receives NSError

/*
 Main constructor to use to set up a new uploader
 JADropboxFileCheckWrapper *checker = [JADropboxFileCheckWrapper checkerWithPaths:... */
+(JADropboxFileCheckWrapper *)checkerWithPaths:(NSMutableDictionary *)paths completed:(JADropboxCheckerCompletedBlock)compBlock failed:(JADropboxCheckerFailedBlock)failBlock;

/*
 Begin upload work
 example:
 JADropboxFileCheckWrapper *checker = [JADropboxFileCheckWrapper checkerWithPaths:...
 [checker checkFile]; */
-(void)checkFile;


@end
