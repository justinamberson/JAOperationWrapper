
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
 JADropboxUploadWrapper.m
 */

#import "JAUploadWrapperGoogleDrive.h"
#import "GTMOAuth2ViewControllerTouch.h"
#import "GTLDrive.h"

@interface JAUploadWrapperGoogleDrive ()
@property (nonatomic,strong) GTLServiceTicket *uploadTicket;
@property (nonatomic,strong) GTLServiceDrive *service;
@end

@implementation JAUploadWrapperGoogleDrive
@synthesize service,uploadTicket;

#warning replace the following defines with your keys
#define GOOGLE_DRIVE_CLIENT_ID Google_Drive_Client_ID
#define GOOGLE_DRIVE_CLIENT_SECRET Google_Drive_Client_Secret
#define GOOGLE_DRIVE_KEYCHAIN_NAME Google_Drive_Service_Name
#warning replace the previous defines with your keys

-(void)upload {
    
    if (! self.service) {
        self.service = [[GTLServiceDrive alloc] init];
        self.service.authorizer = [GTMOAuth2ViewControllerTouch authForGoogleFromKeychainForName:GOOGLE_DRIVE_KEYCHAIN_NAME clientID:GOOGLE_DRIVE_CLIENT_ID clientSecret:GOOGLE_DRIVE_CLIENT_SECRET];
    }
    
    GTLDriveFile *file = [GTLDriveFile object];
    NSString *fileName = [self.pathsDictionary objectForKey:JAFileUploadNameKey];
    file.title = fileName;
    NSString *localFilePath = [self.pathsDictionary objectForKey:JAFileUploadLocalPathKey];
    NSString *fileID = [self.pathsDictionary objectForKey:JAFileUploadFileIDKey];
    NSString *parentID = [self.pathsDictionary objectForKey:JAFileUploadPathIDKey];
    if (parentID) {
        GTLDriveParentReference *ref = [GTLDriveParentReference object];
        ref.identifier = parentID;
        file.parents = [NSArray arrayWithObject:ref];
    }
    //NSFileHandle *fileHandle = [NSFileHandle fileHandleForReadingAtPath:localFilePath];
    //GTLUploadParameters *uploadParameters = [GTLUploadParameters uploadParametersWithFileHandle:fileHandle MIMEType:@"audio/mp4"];
    
    NSData *fileData = [[NSData alloc]initWithContentsOfFile:localFilePath];
    
    GTLUploadParameters *uploadParameters = [GTLUploadParameters uploadParametersWithData:fileData MIMEType:nil];
    GTLQueryDrive *query;
    if (fileID) {
        query = [GTLQueryDrive queryForFilesUpdateWithObject:file fileId:fileID uploadParameters:uploadParameters];
    } else {
        query = [GTLQueryDrive queryForFilesInsertWithObject:file uploadParameters:uploadParameters];
    }
    NSMutableDictionary __block *myPathsDict = self.pathsDictionary;
    JAUploadProgressBlock __block myProgressBlock = self.progressBlock;
    self.uploadTicket = [self.service executeQuery:query
                  completionHandler:^(GTLServiceTicket *ticket,
                                      GTLDriveFile *insertedFile, NSError *error) {
            

                      if (error == nil)
                      {
                          NSDate *now = [NSDate date];
                          NSLog(@"Inserted File: %@",insertedFile);
                          [self.pathsDictionary setObject:now forKey:JAFileUploadDateKey];
                          [self.pathsDictionary setObject:insertedFile.identifier forKey:JAFileUploadFileIDKey];
                          self.completedBlock(self.pathsDictionary);
                      }
                      else
                      {
                          self.failedBlock(error);
                      }
                  }];
    [uploadTicket setUploadProgressBlock:^(GTLServiceTicket *ticket, unsigned long long bytesRead, unsigned long long dataLength) {
        
        CGFloat percentage = (CGFloat)bytesRead/(CGFloat)dataLength;
        NSNumber *percentWrapper = [NSNumber numberWithFloat:percentage];
        [myPathsDict setObject:percentWrapper forKey:JAFileUploadPercentageKey];
        myProgressBlock(myPathsDict);
    }];

}

-(void)createNewFolderNamed:(NSString *)folderName inParent:(NSString *)parentName {
    GTLDriveFile *folder = [GTLDriveFile object];
    folder.title = folderName;
    if (parentName) {
        NSDictionary *folderParents = [NSDictionary dictionaryWithObjectsAndKeys:@"id",parentName, nil];
        NSArray *parentArray = [NSArray arrayWithObject:folderParents];
        folder.parents = parentArray;
    }
    
    GTLUploadParameters *folderParams = [GTLUploadParameters uploadParametersWithData:nil MIMEType:@"application//vnd.google-apps.folder"];
    GTLQueryDrive *folderQuery = [GTLQueryDrive queryForFilesInsertWithObject:folder uploadParameters:folderParams];
    [self.service executeQuery:folderQuery completionHandler:^(GTLServiceTicket *ticket, id object, NSError *error) {
        
    }];
}

-(void)cancelUpload {
    [uploadTicket cancelTicket];
}

@end
