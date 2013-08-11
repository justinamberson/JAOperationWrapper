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
 JAUploadWrapper.m
 */

#import "JAUploadWrapper.h"

@interface JAUploadWrapper ()

-(id)initWithPaths:(NSMutableDictionary *)paths progress:(JAUploadProgressBlock)progBlock completed:(JAUploadCompletedBlock)compBlock failed:(JAUploadFailedBlock)failBlock;
@end

@implementation JAUploadWrapper

#pragma mark -
#pragma mark object init methods

-(id)initWithPaths:(NSMutableDictionary *)paths progress:(JAUploadProgressBlock)progBlock completed:(JAUploadCompletedBlock)compBlock failed:(JAUploadFailedBlock)failBlock {
    if (self = [super init]) {
        self.pathsDictionary = paths;
        _failedBlock = failBlock;
        _completedBlock = compBlock;
        _progressBlock = progBlock;
    }
    return self;
}

+(id)uploaderWithPaths:(NSMutableDictionary *)paths progress:(JAUploadProgressBlock)progBlock completed:(JAUploadCompletedBlock)compBlock failed:(JAUploadFailedBlock)failBlock {
    return [[[self class] alloc]initWithPaths:paths progress:progBlock completed:compBlock failed:failBlock];
}

-(void)upload {
    NSLog(@"You must override this method in your subclass. Perform needed setup here, wire up delegates, etc.");
}


@end
