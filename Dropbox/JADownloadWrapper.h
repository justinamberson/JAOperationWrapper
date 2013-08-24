//
//  JADownloadWrapper.h
//  DataDeposit2
//
//  Created by JUSTIN AMBERSON on 8/23/13.
//  Copyright (c) 2013 justinxxvii. All rights reserved.
//

#import <Foundation/Foundation.h>
typedef void (^JADownloadProgressBlock)(NSMutableDictionary *uploadInfo);
typedef void (^JADownloadCompletedBlock)(NSMutableDictionary *uploadInfo);
typedef void (^JADownloadFailedBlock)(NSError *error);

@interface JADownloadWrapper : NSObject

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
@property (nonatomic,copy) JADownloadProgressBlock progressBlock; //receives pathsDictionary
@property (nonatomic,copy) JADownloadCompletedBlock completedBlock; //receives pathsDictionary
@property (nonatomic,copy) JADownloadFailedBlock failedBlock; //receives NSError

/*
 Main constructor to use to set up a new uploader
 JAFileUploadWrapper *uploader = [JAFileUploader uploaderWithPaths:...
 */
+(id)downloaderWithPaths:(NSMutableDictionary *)paths progress:(JADownloadProgressBlock)progBlock completed:(JADownloadCompletedBlock)compBlock failed:(JADownloadFailedBlock)failBlock;

/*
 Begin upload work
 example:
 JAUploadWrapper *uploader = [JAUploadWrapper uploaderWithPaths:...
 [uploader upload]; */
-(void)download;

/*
 Cancel current upload
 Subclasses should override
 */
-(void)cancelDownload;


@end
