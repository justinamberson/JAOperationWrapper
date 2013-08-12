### JAOperationWrapper ###

Objective-C wrapper classes for uploading files to backup and sync services.

The mission of this project is to create a platform for easily saving files using a simple block based interface that is identical across platforms. It will be as easy as passing a dictionary to a subclass. 

Support for writing subclasses is baked in. Currently all that is needed is to override one method. 

### How it works ###

For example, the included Dropbox subclass:

    #import "JADropboxUploadWrapper.h"

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
			CGFloat progressFloat = [progress floatValue]; 
			NSLog(@"Uploaded %.2f",progressFloat);
	
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


### To Do ###

Currently the project only has support for Dropbox and Box.com. I'd like to include wrappers for Google Drive and SugarSync in the future. I encourage others to build and share their own subclasses back with the project.

### Getting Started ###

To get started, drag and drop the files you need to use into your project folder. Have XCode add groups for any folder references. Add them to your target. Copying to the project directory is not required. You have to set up SDKs for Dropbox and Box.com independently.