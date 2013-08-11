
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
 JABoxComUploadWrapper.h
 */

#import "JABoxComUploadOperation.h"
@interface JABoxComUploadOperation ()

@end

@implementation JABoxComUploadOperation

-(void)start {
    
    if (![NSThread isMainThread]) {
        
        [self performSelectorOnMainThread:@selector(start) withObject:nil waitUntilDone:NO];
        return;
    }
    UIApplication *app = [UIApplication sharedApplication];
    [app setIdleTimerDisabled:YES];
    UIBackgroundTaskIdentifier bgTask = 0;
    bgTask = [app beginBackgroundTaskWithExpirationHandler:^
              {
                  [app endBackgroundTask:bgTask];
                  
    }]; 
    self.uploadWrapper = [JABoxComUploadWrapper uploaderWithPaths:self.itemToUpload progress:^(NSMutableDictionary *uploadInfo) {
        
        if (self.isCancelled) {
            [self.uploadWrapper.boxUploadOperation cancel];
            [self updateCompletedState];
            [app endBackgroundTask:bgTask];
        }
        [self.operationDelegate uploadOperation:self didUploadPercentageForItem:uploadInfo];
        
    } completed:^(NSMutableDictionary *info) {
        
        [self.operationDelegate uploadOperation:self uploadedLocalFileWithInfo:info];
        [app endBackgroundTask:bgTask];
        
    } failed:^(NSError *error) {
        
        [self.operationDelegate uploadOperation:self uploadFailedWithError:error];
        [app endBackgroundTask:bgTask];
        
    }];
    [_uploadWrapper upload];
    

}

@end
