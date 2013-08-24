//
//  JAFileSystemDropbox.m
//  DataDeposit2
//
//  Created by JUSTIN AMBERSON on 8/24/13.
//  Copyright (c) 2013 justinxxvii. All rights reserved.
//

#import "JAFileSystemDropbox.h"
#import <DropboxSDK/DropboxSDK.h>

@implementation JAFileSystemDropbox
@synthesize dbClient;

-(void)fetch {
    self.dbClient = [[DBRestClient alloc]initWithSession:[DBSession sharedSession]];
    self.dbClient.delegate = self;
    
    NSMutableString *remotePathString = [NSMutableString string];
    [remotePathString appendString:@"/"];
    for (NSString *component in self.pathComponents) {
        [remotePathString appendString:component];
        [remotePathString appendString:@"/"];
    }
    [self.dbClient loadMetadata:remotePathString];
}

-(void)restClient:(DBRestClient *)client loadedMetadata:(DBMetadata *)metadata {
    NSMutableArray *array = [NSMutableArray array];
    [array addObject:@"Success!"];
    self.completionBlock(array);
}

-(void)restClient:(DBRestClient *)client loadMetadataFailedWithError:(NSError *)error {
    self.failedBlock(error);
}

@end
