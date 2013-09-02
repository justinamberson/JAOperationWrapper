//
//  JAFileSystemBoxCom.m
//  DataDeposit2
//
//  Created by JUSTIN AMBERSON on 8/25/13.
//  Copyright (c) 2013 justinxxvii. All rights reserved.
//

#import "JAFileSystemBoxCom.h"
#import "JAOperationWrapperConstants.h"

@interface JAFileSystemBoxCom ()
@property (nonatomic,assign) NSInteger pathComponentIndex;
@property (nonatomic,assign) BOOL didCreateFolders;
@property (nonatomic,strong) NSString *currentParentID;
@end

@implementation JAFileSystemBoxCom
@synthesize requestBuilder;
@synthesize pathComponentIndex;
@synthesize didCreateFolders;
@synthesize currentParentID;

-(void)fetch {
    self.pathComponentIndex = 0;
    if (!requestBuilder) {
        self.requestBuilder = [[BoxFoldersRequestBuilder alloc]init];
    }
    [self queryForFoldersWithInParentID:BoxAPIFolderIDRoot];
}

-(void)checkForFiles {
    
    NSString *parentID = self.currentParentID;
    //NSString *fileName = [self.pathsDictionary objectForKey:JAFileUploadNameKey];
    
    if (parentID) {
        [[BoxSDK sharedSDK].foldersManager folderItemsWithID:parentID requestBuilder:requestBuilder success:^(BoxCollection *collection) {
            NSUInteger i;
            NSMutableArray *remoteFilesArray = [NSMutableArray array];
            for (i = 0;i<collection.numberOfEntries;i++) {
                BoxModel *model = [collection modelAtIndex:i];
                NSDictionary *json = model.rawResponseJSON;
                NSString *name = [json objectForKey:@"name"];
                NSString *fileID = [json objectForKey:@"id"];
    
                NSMutableDictionary *fileDict = [NSMutableDictionary dictionary];
                [fileDict setObject:name forKey:JAFileDownloadNameKey];
                [fileDict setObject:fileID forKey:JAFileDownloadRemotePathKey];
                [fileDict setObject:fileID forKey:JAFileDownloadFileIDKey];
                if (self.currentParentID) {
                    [fileDict setObject:self.currentParentID forKey:JAFileDownloadPathIDKey];
                }
                [remoteFilesArray addObject:fileDict];
            }
            self.completionBlock(remoteFilesArray);
        } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, NSDictionary *JSONDictionary) {
            NSLog(@"Box File Check Failed With Error: %@",error.localizedDescription);
            self.failedBlock(error);
        }];
    } else {
        [[BoxSDK sharedSDK].foldersManager folderItemsWithID:BoxAPIFolderIDRoot requestBuilder:requestBuilder success:^(BoxCollection *collection) {
            NSUInteger i;
            NSMutableArray *remoteFilesArray = [NSMutableArray array];

            for (i = 0;i<collection.numberOfEntries;i++) {
                BoxModel *model = [collection modelAtIndex:i];
                NSDictionary *json = model.rawResponseJSON;
                NSString *name = [json objectForKey:@"name"];
                NSString *fileID = [json objectForKey:@"id"];
                
                NSMutableDictionary *fileDict = [NSMutableDictionary dictionary];
                [fileDict setObject:name forKey:JAFileDownloadNameKey];
                [fileDict setObject:fileID forKey:JAFileDownloadRemotePathKey];
                [fileDict setObject:fileID forKey:JAFileDownloadFileIDKey];
                if (self.currentParentID) {
                    [fileDict setObject:self.currentParentID forKey:JAFileDownloadPathIDKey];
                }
                [remoteFilesArray addObject:fileDict];
                
            }
            self.completionBlock(remoteFilesArray);
        } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, NSDictionary *JSONDictionary) {
            NSLog(@"Box File Check Failed With Error: %@",error.localizedDescription);
            self.failedBlock(error);
        }];
        
    }
    
}

-(void)queryForFoldersWithInParentID:(NSString *)parentID {
    
    NSString *thisComponent = [self getNextComponentFromPathComponents:self.pathComponents];
    
    if (!thisComponent) {
        //we did NOT find a thisComponent
        //it is nil, so what do we do now?
        
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
    BOOL __block didFind = NO;
    BoxFoldersRequestBuilder *folderQuery = [[BoxFoldersRequestBuilder alloc]init];
    [[BoxSDK sharedSDK].foldersManager folderItemsWithID:parentID requestBuilder:folderQuery success:^(BoxCollection *collection) {
        NSUInteger i;
        for (i = 0;i<collection.numberOfEntries;i++) {
            BoxModel *model = [collection modelAtIndex:i];
            NSDictionary *json = model.rawResponseJSON;
            NSString *name = [json objectForKey:@"name"];
            NSString *type = [json objectForKey:@"type"];
            if ([type isEqualToString:@"folder"] && [name isEqualToString:thisComponent]) {
                NSLog(@"Found %@",name);
                //Found folder. Need to traverse its contents
                didFind = YES;
                NSString *folderParentID = [json objectForKey:@"id"];
                self.currentParentID = folderParentID;
                [self queryForFoldersWithInParentID:folderParentID];
                return;
            }
            
        }
        if (!didFind) {
            [self createFolderWithName:thisComponent inParent:parentID];
        }
        
        
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, NSDictionary *JSONDictionary) {
        NSLog(@"Query For Box Folders Error: %@",error.localizedDescription);
        self.failedBlock(error);
    }];
    
}

-(void)createFolderWithName:(NSString *)name inParent:(NSString *)parentID {
    BoxFoldersRequestBuilder *newFolder = [[BoxFoldersRequestBuilder alloc]init];
    newFolder.name = name;
    newFolder.parentID = parentID;
    [[BoxSDK sharedSDK].foldersManager createFolderWithRequestBuilder:newFolder success:^(BoxFolder *folder) {
        NSLog(@"New Box Folder: %@",folder);
        NSDictionary *json = folder.rawResponseJSON;
        NSString *theFolderID = [json objectForKey:@"id"];
        NSLog(@"Created folder %@ that has ID %@",name,theFolderID);
        self.didCreateFolders = YES;
        if (![[self.pathComponents lastObject] isEqualToString:name]) {
            [self queryForFoldersWithInParentID:theFolderID];
        } else {
            
            self.completionBlock(nil);
            return;
        }
        
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, NSDictionary *JSONDictionary) {
        NSLog(@"Create Box Folder failed with error: %@",error.localizedDescription);
        self.failedBlock(error);
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
