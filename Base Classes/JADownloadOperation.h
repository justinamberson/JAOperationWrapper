//
//  JADownloadOperation.h
//  DataDeposit2
//
//  Created by JUSTIN AMBERSON on 8/23/13.
//  Copyright (c) 2013 justinxxvii. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol JADownloadOperationDelegate <NSObject>

-(void)downloadOperation:(id)operation didDownloadPercentageForItem:(NSMutableDictionary *)uploadInfo;
-(void)downloadOperation:(id)operation downloadFailedWithError:(NSError *)error;
-(void)downloadOperation:(id)operation downloadedLocalFileWithInfo:(NSMutableDictionary *)infoDict;

@end

@interface JADownloadOperation : NSOperation

/*
 NSMutableDictionary *itemToUpload - should contain objects with these keys:
 NSString *const JAFileUploadNameKey
 NSString *const JAFileUploadRemotePathKey
 NSString *const JAFileUploadPathIDKey
 NSString *const JAFileUploadLocalPathKey */
@property (nonatomic,strong) NSMutableDictionary *itemToDownload;

/*
 Delegate object to receive callbacks didUploadPercentage, uploadFailedWithError,
 and uploadedLocalFileWithInfo */
@property (nonatomic,weak) id <JADownloadOperationDelegate> operationDelegate;

/*
 Main constructor method */
-(id)initWithDownloadInfo:(NSMutableDictionary *)info;

/*
 Call this to end the NSOperation lifecycle */
-(void)updateCompletedState;


@end
