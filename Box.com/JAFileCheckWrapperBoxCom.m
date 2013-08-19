
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
 JABoxComFileCheckWrapper.m
 */
#import "JAFileCheckWrapperBoxCom.h"
#import "JAOperationWrapperConstants.h"

@interface JAFileCheckWrapperBoxCom ()
@property (nonatomic,assign) NSInteger pathComponentIndex;
@property (nonatomic,assign) BOOL didCreateFolders;
@end


@implementation JAFileCheckWrapperBoxCom
@synthesize pathComponentIndex,didCreateFolders;

-(void)checkFile {
    if (!self.checker) {
        self.checker = [[BoxFoldersRequestBuilder alloc]init];
    }
    
	[self queryForFoldersWithInParentID:BoxAPIFolderIDRoot];
}

-(void)checkForFile {
    
    NSString *parentID = [self.pathsDictionary objectForKey:JAFileUploadPathIDKey];
    NSString *fileName = [self.pathsDictionary objectForKey:JAFileUploadNameKey];
    
    if (parentID) {
        [[BoxSDK sharedSDK].foldersManager folderItemsWithID:parentID requestBuilder:_checker success:^(BoxCollection *collection) {
            NSUInteger i;
            for (i = 0;i<collection.numberOfEntries;i++) {
                BoxModel *model = [collection modelAtIndex:i];
                NSDictionary *json = model.rawResponseJSON;
                NSString *name = [json objectForKey:@"name"];
                NSString *type = [json objectForKey:@"type"];
                if ([type isEqualToString:@"file"] && [name isEqualToString:fileName]) {
                    NSString *fileID = [json objectForKey:@"id"];
                    [self.pathsDictionary setObject:fileID forKey:JAFileUploadFileIDKey];
                }
                
            }
            self.completedBlock(self.pathsDictionary);
        } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, NSDictionary *JSONDictionary) {
            NSLog(@"Box File Check Failed With Error: %@",error.localizedDescription);
            self.failedBlock(error);
        }];
    } else {
        [[BoxSDK sharedSDK].foldersManager folderItemsWithID:BoxAPIFolderIDRoot requestBuilder:_checker success:^(BoxCollection *collection) {
            NSUInteger i;
            for (i = 0;i<collection.numberOfEntries;i++) {
                BoxModel *model = [collection modelAtIndex:i];
                NSDictionary *json = model.rawResponseJSON;
                NSString *name = [json objectForKey:@"name"];
                NSString *type = [json objectForKey:@"type"];
                if ([type isEqualToString:@"file"] && [name isEqualToString:fileName]) {
                    NSString *fileID = [json objectForKey:@"id"];
                    [self.pathsDictionary setObject:fileID forKey:JAFileUploadFileIDKey];
                }
            }
            self.completedBlock(self.pathsDictionary);
        } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, NSDictionary *JSONDictionary) {
            NSLog(@"Box File Check Failed With Error: %@",error.localizedDescription);
            self.failedBlock(error);
        }];

    }

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
                    [self.pathsDictionary setObject:folderParentID forKey:JAFileUploadPathIDKey];
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
    NSArray *pathComponents = [self.pathsDictionary objectForKey:JAFileUploadRemotePathKey];
    BoxFoldersRequestBuilder *newFolder = [[BoxFoldersRequestBuilder alloc]init];
    newFolder.name = name;
    newFolder.parentID = parentID;
    [[BoxSDK sharedSDK].foldersManager createFolderWithRequestBuilder:newFolder success:^(BoxFolder *folder) {
        NSLog(@"New Box Folder: %@",folder);
        NSDictionary *json = folder.rawResponseJSON;
        NSString *currentFolderID = [json objectForKey:@"id"];
        NSLog(@"Created folder %@ that has ID %@",name,currentFolderID);
        self.didCreateFolders = YES;
        if (![[pathComponents lastObject] isEqualToString:name]) {
            [self queryForFoldersWithInParentID:currentFolderID];
        } else {
            //No more folders to create, set the parent ID key
            //The fileCheck will be completed after this
            [self.pathsDictionary setObject:currentFolderID forKey:JAFileUploadPathIDKey];
            //Otherwise, we DID create folders and there will be
            //no chance that the file exists at this path.
            //parentID key was already set. Now when the upload happens
            //it will be in the parent folder
            self.completedBlock(self.pathsDictionary);
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
