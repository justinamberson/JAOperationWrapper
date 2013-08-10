
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
#import <BoxSDK/BoxSDK.h>

@interface JABoxComFileCheckWrapper ()
@property (nonatomic,strong) DBRestClient *dbClient;
-(id)initWithPaths:(NSMutableDictionary *)paths completed:(JABoxComCheckerCompletedBlock)compBlock failed:(JABoxComCheckerFailedBlock)failBlock;
@end


@implementation JABoxComFileCheckWrapper


-(id)initWithPaths:(NSMutableDictionary *)paths completed:(JABoxComCheckerCompletedBlock)compBlock failed:(JABoxComCheckerFailedBlock)failBlock {
	if (self = [super init]) {
        self.pathsDictionary = paths;
        _completedBlock = compBlock;
        _failedBlock = failBlock;
	}
	return self;
}

+(JABoxComFileCheckWrapper *)checkerWithPaths:(NSMutableDictionary *)paths completed:(JABoxComCheckerCompletedBlock)compBlock failed:(JABoxComCheckerFailedBlock)failBlock {
    return [[JABoxComFileCheckWrapper alloc] initWithPaths:paths completed:compBlock failed:failBlock];
}

-(void)checkFile {
    NSString *remotePath = [self.pathsDictionary objectForKey:JAFileUploadNameKey];
    _isChecking = YES;
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
            _isChecking = NO;
        }
        _completedBlock(_pathsDictionary);
    };
    BoxAPIJSONFailureBlock checkFailBlock = ^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, NSDictionary *JSONDictionary) {
        _failedBlock(error);
        _isChecking = NO;
    };
    BoxFoldersRequestBuilder *checker = [[BoxFoldersRequestBuilder alloc]init];
    [[BoxSDK sharedSDK].foldersManager folderItemsWithID:BoxAPIFolderIDRoot requestBuilder:checker success:checkSuccessBlock failure:checkFailBlock];


}



@end
