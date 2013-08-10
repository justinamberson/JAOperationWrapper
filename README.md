JAOperationWrapper ==================

Objective-C wrapper classes for uploading files to backup and sync services.

The mission of this project is to create easy to use block-based wrappers around existing SDKs that allow for easy uploading to online sync services like Dropbox. Wrappers should be created that conform to a specific specification. See this example:

```html
#import "JADropboxUploadWrapper.h"
#
...

/*  
    First Create an NSMutableDictionary with keys that represent the following items:

    File's name as it will be represented on the service (song.mp3, resume.txt etc) 
    File's local path on the filesystem ( /Sandbox/Library/data.bin) 
    Intended remote path on the service ( /AppDirectory/Subdirectory) 
    File's "unique identifier" on the service. 
    Dropbox has a "parent revision" For instance, if the Dropbox parent revision is known, the file will be overwritten If the parent revision is unknown, a new file will be created (song (1).mp3) 

*/

NSMutableDictionary *fileRepresentation = [NSMutableDictionary dictionary];

/*
	There are several string constants included with the project. You will need:
	JAFileUploadNameKey - For the file's name as it will appear on the service
	JAFileUploadLocalPathKey - For the file's local path on the filesystem
	JAFileUploadRemotePathKey - For the file's remote path on the service
	JAFileUploadPathIDKey - For the file's "unique identifier" on the service 
*/

[fileRepresentation setObject:@"mySong.mp3" forKey:JAFileUploadNameKey];
[fileRepresentation setObject:@"/Path/To/Song/mySong.mp3" forKey:JAFileUploadLocalPathKey];
[fileRepresentation setObject:@"/Music/Songs" forKey:JAFileUploadRemotePathKey];
[fileRepresentation setObject:knownParentRev forKey:JAFileUploadPathIDKey];

JADropboxUploadWrapper *wrapper = [JADropboxUploadWrapper uploaderWithPaths:fileRepresentation progress:^(NSMutableDictionary *uploadInfo) {
		//Receive the submitted NSMutableDictionary again in this block. There will be an
		//updated NSNumber object wrapping a CGFloat with a new progress value.
		NSNumber *progress = [uploadInfo objectForKey:JAFileUploadPercentageKey]; 
		CGFloat progressFloat = [progress floatValue]; NSLog(@"Uploaded %.2f",progressFloat);

    } completed:^(NSMutableDictionary *uploadInfo) {
        //Receive the submitted NSMutableDictionary again in this block. Signifies that
        //the upload has completed without issue.
        NSLog(@"Completed upload on file: %@",uploadInfo);

    } failed:^(NSError *error) {
        //Receive an NSError
        NSLog(@"Error Received: %@",[error localizedDescription]);
    }];
//Perform the upload    
[wrapper upload]; //You must call this method
```

Wrapper classes should conform to that spec. They should offer block based callbacks, one for monitoring progress, one for completion, and one for error. They should not begin automatically and instead offer a method called upload to begin.

Currently the project only has support for Dropbox and Box.com. I'd like to include wrappers for Google Drive and SugarSync in the future.

To get started, drag and drop the files you need to use into your project folder. You have to set up SDKs for Dropbox and Box.com independently.