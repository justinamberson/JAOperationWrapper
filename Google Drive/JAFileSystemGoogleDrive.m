//
//  JAFileSystemGoogleDrive.m
//  DataDeposit2
//
//  Created by JUSTIN AMBERSON on 8/25/13.
//  Copyright (c) 2013 justinxxvii. All rights reserved.
//

#import "JAFileSystemGoogleDrive.h"
#import "GTMOAuth2ViewControllerTouch.h"
#import "JAOperationWrapperConstants.h"

@interface JAFileSystemGoogleDrive ()
@property (nonatomic,assign) NSInteger pathComponentIndex;
@property (nonatomic,assign) BOOL didCreateFolders;
@property (nonatomic,strong) NSString *currentParentID;
@end

#warning replace the following defines with your keys
#define GOOGLE_DRIVE_CLIENT_ID Google_Drive_Client_ID
#define GOOGLE_DRIVE_CLIENT_SECRET Google_Drive_Client_Secret
#define GOOGLE_DRIVE_KEYCHAIN_NAME Google_Drive_Service_Name

@implementation JAFileSystemGoogleDrive
@synthesize service;
@synthesize pathComponentIndex;
@synthesize didCreateFolders;
@synthesize currentParentID;

-(void)fetch {
    self.pathComponentIndex = 0;
    if (!self.service) {
        self.service = [[GTLServiceDrive alloc]init];
        self.service.authorizer = [GTMOAuth2ViewControllerTouch authForGoogleFromKeychainForName:GOOGLE_DRIVE_KEYCHAIN_NAME clientID:GOOGLE_DRIVE_CLIENT_ID clientSecret:GOOGLE_DRIVE_CLIENT_SECRET];
    }
    [self queryForFoldersWithInParentID:@"root"];
}

-(void)checkForFiles {
    NSString *parentID = self.currentParentID;
    GTLQueryDrive *query = [GTLQueryDrive queryForFilesList];
    query.q = [NSString stringWithFormat:@"'%@' in parents and trashed=false",parentID];
    query.maxResults = 100000;
    [self.service executeQuery:query completionHandler:^(GTLServiceTicket *ticket, id object, NSError *error) {
        if (!error) {
            GTLDriveFileList *list = (GTLDriveFileList *)object;
            NSMutableArray *remoteFileList = [NSMutableArray array];
            for (GTLDriveFile *file in list.items) {
                NSLog(@"Found File: \n \n \n %@ \n \n",file);
                NSMutableDictionary *dict = [NSMutableDictionary dictionary];
                NSString *fileID = file.identifier;
                NSString *fileName = file.originalFilename;
                GTLDateTime *modifiedDateObject = file.modifiedByMeDate;
                NSDate *modifiedDate = modifiedDateObject.date;
                [dict setObject:fileName forKey:JAFileDownloadNameKey];
                [dict setObject:fileID forKey:JAFileDownloadFileIDKey];
                if (modifiedDate) {
                    [dict setObject:modifiedDate forKey:JAFileDownloadDateKey];
                }
                if (self.currentParentID) {
                    [dict setObject:self.currentParentID forKey:JAFileDownloadPathIDKey];
                }
                [dict setObject:fileID forKey:JAFileDownloadRemotePathKey];
                /*
                if ([fileName isEqualToString:file.originalFilename]) {
                    NSString *fileID = file.identifier;
                    [self.pathsDictionary setObject:fileID forKey:JAFileUploadFileIDKey];
                    for (GTLDriveParentReference *parent in file.parents) {
                        if ([parent.kind isEqualToString:@"drive#parentReference"]) {
                            [self.pathsDictionary setObject:parent.identifier forKey:JAFileUploadPathIDKey];
                        }
                    }
                }
                 */
                [remoteFileList addObject:dict];
            }
            self.completionBlock(remoteFileList);
        } else {
            NSLog(@"%@",error);
            self.failedBlock(error);
        }
    }];
    
}

-(void)queryForFoldersWithInParentID:(NSString *)parentID {
    
    
    
    NSString *thisComponent = [self getNextComponentFromPathComponents:self.pathComponents];
    
    if (!thisComponent) {
        //nothing left in the array, already found or created the last directory
        if (!self.didCreateFolders) {
            //If we DID NOT create folders, it's possible
            //that the file exists at this path already. so check
            //for this file now
            [self checkForFiles];
            return;
        } else {
            //Otherwise, we DID create folders and there will be
            //no chance that the file exists at this path.
            //parentID key was already set. Now when the upload happens
            //it will be in the parent folder
            self.completionBlock(nil);
            return;
        }
        
        
    }
    
    GTLQueryDrive *query = [GTLQueryDrive queryForFilesList];
    
    if (!parentID) {
        query.q = @"mimeType='application/vnd.google-apps.folder' and 'root' in parents and trashed=false";
    } else {
        query.q = [NSString stringWithFormat:@"mimeType='application/vnd.google-apps.folder' and '%@' in parents and trashed=false",parentID];
    }
    
    query.maxResults = 100000;
    BOOL __block didFind = NO;
    [self.service executeQuery:query completionHandler:^(GTLServiceTicket *ticket, id object, NSError *error) {
        
        if (!error) {
            
            
            GTLDriveFileList *list = (GTLDriveFileList *)object;
            for (GTLDriveFile *file in list.items) {
                
                NSString *folderParentID = file.identifier;
                if (thisComponent) {
                    
                    if ([thisComponent isEqualToString:file.title]) {
                        NSLog(@"Found %@",file.title);
                        //Found folder. Need to traverse its contents
                        didFind = YES;
                        self.currentParentID = folderParentID;
                        [self queryForFoldersWithInParentID:folderParentID];
                        return;
                    }
                }
            }
        } else {
            NSLog(@"Folder Query Error: %@",error);
            self.failedBlock(error);
        }
        if (!didFind) {
            [self createFolderWithName:thisComponent inParent:parentID];
        }
    }];
    
    
}

-(void)createFolderWithName:(NSString *)name inParent:(NSString *)parentID {
    GTLDriveFile *newFolder = [GTLDriveFile object];
    newFolder.title = name;
    newFolder.mimeType = @"application/vnd.google-apps.folder";
    
    GTLDriveParentReference *ref = [GTLDriveParentReference object];
    if (parentID) {
        ref.identifier = parentID;
        newFolder.parents = [NSArray arrayWithObject:ref];
    } else {
        ref.identifier = @"root";
        newFolder.parents = [NSArray arrayWithObject:ref];
    }
    
    GTLQueryDrive *insertFolderQuery = [GTLQueryDrive queryForFilesInsertWithObject:newFolder uploadParameters:nil];
    
    [self.service executeQuery:insertFolderQuery completionHandler:^(GTLServiceTicket *ticket, id object, NSError *error) {
        if (!error) {
            GTLDriveFile *insertedFile = object;
            NSString *currentFileId = insertedFile.identifier;
            NSLog(@"Created folder %@ that has ID %@",name,currentFileId);
            self.didCreateFolders = YES;
            if (![[self.pathComponents lastObject] isEqualToString:name]) {
                NSLog(@"Still objects left in path");
                [self queryForFoldersWithInParentID:currentFileId];
            } else {
                //No more folders to create, set the parent ID key
                //The fileCheck will be completed after this
                
                //Otherwise, we DID create folders and there will be
                //no chance that the file exists at this path.
                //parentID key was already set. Now when the upload happens
                //it will be in the parent folder
                self.completionBlock(nil);
                return;
            }
        } else {
            NSLog(@"Create Folder failed with error: %@",error.localizedDescription);
            self.failedBlock(error);
        }
    }];
}

-(NSString *)getNextComponentFromPathComponents:(NSArray *)pathComponents {
    /*
     This function takes the pathComponents array (sourced from JAFileUploadRemotePathKey)
     and obtains the string at the index that is controlled by this class, pathComponentIndex
     Afterwards it increments the index by 1. When the time comes that the index goes
     out of bounds, it will return nil, so other methods know that the end of the
     array has been reached.
     */
    
    NSString *nextComponent;
    if (pathComponentIndex <= pathComponents.count - 1) {
        nextComponent = [pathComponents objectAtIndex:pathComponentIndex];
        pathComponentIndex += 1;
        return nextComponent;
    }
    return nil;
}



@end
