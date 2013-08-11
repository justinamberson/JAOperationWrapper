
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
#import "JABoxComFileCheckWrapper.h"
#import "JAOperationWrapperConstants.h"

@interface JABoxComFileCheckWrapper ()

@end


@implementation JABoxComFileCheckWrapper

-(void)checkFile {
    
	NSString *parentID = [self.pathsDictionary objectForKey:JAFileUploadRemotePathKey];
    NSString *remotePath = [self.pathsDictionary objectForKey:JAFileUploadNameKey];
    BoxCollectionBlock checkSuccessBlock = ^(BoxCollection *collection) {
        NSUInteger i;
        for (i = 0;i<collection.numberOfEntries;i++) {
            BoxModel *model = [collection modelAtIndex:i];
            NSDictionary *json = model.rawResponseJSON;
            NSString *name = [json objectForKey:@"name"];
            NSString *type = [json objectForKey:@"type"];
            if ([type isEqualToString:@"file"] && [name isEqualToString:remotePath]) {
                NSString *fileID = [json objectForKey:@"id"];
                [self.pathsDictionary setObject:fileID forKey:JAFileUploadPathIDKey];
            }
            
        }
        self.completedBlock(self.pathsDictionary);
    };
    BoxAPIJSONFailureBlock checkFailBlock = ^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, NSDictionary *JSONDictionary) {
        self.failedBlock(error);
        
    };
    self.checker = [[BoxFoldersRequestBuilder alloc]init];
    
    if (parentID) {
    	 [[BoxSDK sharedSDK].foldersManager folderItemsWithID:parentID requestBuilder:_checker success:checkSuccessBlock failure:checkFailBlock];
    } else {
    	 [[BoxSDK sharedSDK].foldersManager folderItemsWithID:BoxAPIFolderIDRoot requestBuilder:_checker success:checkSuccessBlock failure:checkFailBlock];
    }

}



@end
