
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

#import "JAFileCheckWrapperGoogleDrive.h"
#import "GTMOAuth2ViewControllerTouch.h"

#warning replace the following defines with your keys
#define GOOGLE_DRIVE_CLIENT_ID Google_Drive_Client_ID
#define GOOGLE_DRIVE_CLIENT_SECRET Google_Drive_Client_Secret
#define GOOGLE_DRIVE_KEYCHAIN_NAME Google_Drive_Service_Name

@interface JAFileCheckWrapperGoogleDrive ()
@property (nonatomic,assign) NSInteger pathComponentIndex;
@property (nonatomic,assign) BOOL didCreateFolders;

@end
@implementation JAFileCheckWrapperGoogleDrive

@synthesize fileChecker,pathComponentIndex;

-(void)checkFile {
    self.didCreateFolders = NO;
    self.pathComponentIndex = 0;
    
    if (!self.fileChecker) {
        self.fileChecker = [[GTLServiceDrive alloc]init];
        self.fileChecker.authorizer = [GTMOAuth2ViewControllerTouch authForGoogleFromKeychainForName:GOOGLE_DRIVE_KEYCHAIN_NAME clientID:GOOGLE_DRIVE_CLIENT_ID clientSecret:GOOGLE_DRIVE_CLIENT_SECRET];
    }
    [self queryForFoldersWithInParentID:@"root"];
}

-(void)checkForFile {
    NSString *fileName = [self.pathsDictionary objectForKey:JAFileUploadNameKey];
    NSString *parentID = [self.pathsDictionary objectForKey:JAFileUploadPathIDKey];
    GTLQueryDrive *query = [GTLQueryDrive queryForFilesList];
    query.q = [NSString stringWithFormat:@"title='%@' and '%@' in parents and trashed=false",fileName,parentID];
    query.maxResults = 100000;
    [self.fileChecker executeQuery:query completionHandler:^(GTLServiceTicket *ticket, id object, NSError *error) {
        if (!error) {
            GTLDriveFileList *list = (GTLDriveFileList *)object;
            for (GTLDriveFile *file in list.items) {
                NSLog(@"Found File: \n \n \n %@ \n \n",file);
                if ([fileName isEqualToString:file.originalFilename]) {
                    NSString *fileID = file.identifier;
                    [self.pathsDictionary setObject:fileID forKey:JAFileUploadFileIDKey];
                    for (GTLDriveParentReference *parent in file.parents) {
                        if ([parent.kind isEqualToString:@"drive#parentReference"]) {
                            [self.pathsDictionary setObject:parent.identifier forKey:JAFileUploadPathIDKey];
                        }
                    }
                }
            }
            self.completedBlock(self.pathsDictionary);
        } else {
            NSLog(@"%@",error);
            self.failedBlock(error);
        }
    }];

}

-(void)queryForFoldersWithInParentID:(NSString *)parentID {
    
    NSArray *pathComponents = [self.pathsDictionary objectForKey:JAFileUploadRemotePathKey];
    
    NSString *thisComponent = [self getNextComponentFromPathComponents:pathComponents];
    
    if (!thisComponent) {
        //nothing left in the array, already found or created the last directory
        if (!self.didCreateFolders) {
            //If we DID NOT create folders, it's possible
            //that the file exists at this path already. so check
            //for this file now
            [self checkForFile];
            return;
        } else {
            //Otherwise, we DID create folders and there will be
            //no chance that the file exists at this path.
            //parentID key was already set. Now when the upload happens
            //it will be in the parent folder
            self.completedBlock(self.pathsDictionary);
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
    [self.fileChecker executeQuery:query completionHandler:^(GTLServiceTicket *ticket, id object, NSError *error) {
        
        if (!error) {
            
            
            GTLDriveFileList *list = (GTLDriveFileList *)object;
            for (GTLDriveFile *file in list.items) {
                
                NSString *folderParentID = file.identifier;
                if (thisComponent) {
                    
                    if ([thisComponent isEqualToString:file.title]) {
                        NSLog(@"Found %@",file.title);
                        //Found folder. Need to traverse its contents
                        didFind = YES;
                        [self.pathsDictionary setObject:folderParentID forKey:JAFileUploadPathIDKey];
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
    NSArray *pathComponents = [self.pathsDictionary objectForKey:JAFileUploadRemotePathKey];
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
    
    [self.fileChecker executeQuery:insertFolderQuery completionHandler:^(GTLServiceTicket *ticket, id object, NSError *error) {
        if (!error) {
            GTLDriveFile *insertedFile = object;
            NSString *currentFileId = insertedFile.identifier;
            NSLog(@"Created folder %@ that has ID %@",name,currentFileId);
            self.didCreateFolders = YES;
            if (![[pathComponents lastObject] isEqualToString:name]) {
                NSLog(@"Still objects left in path");
                [self queryForFoldersWithInParentID:currentFileId];
            } else {
                //No more folders to create, set the parent ID key
                //The fileCheck will be completed after this
                [self.pathsDictionary setObject:currentFileId forKey:JAFileUploadPathIDKey];
                    //Otherwise, we DID create folders and there will be
                    //no chance that the file exists at this path.
                    //parentID key was already set. Now when the upload happens
                    //it will be in the parent folder
                    self.completedBlock(self.pathsDictionary);
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
