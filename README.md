### JAOperationWrapper ###

Objective-C wrapper classes for uploading files to backup and sync services.

The mission of this project is to create a platform for easily saving files using a simple block based interface that is identical across platforms. It will be as easy as passing a dictionary to a subclass. 

Support for writing subclasses is baked in. Currently all that is needed is to override one method. 

### How it works ###

For example, the included Dropbox subclass:

    #import "JAUploadWrapperDropbox.h"

    ...

	/*  
	    First Create an NSMutableDictionary with keys that represent the following items:
	
	    1. File's name as it will be represented on the service (song.mp3, resume.txt etc) 
	    2. File's local path on the filesystem ( /Sandbox/Library/data.bin) 
	    3. Intended remote path on the service (NSArray of NSStrings for each folder)
	    	ie: /MyCoolApp/Books/Classics/Jules Verne
	    	==: [NSArray arrayWithObjects:@"MyCoolApp",@"Books",@"Classics",@"Jules Verne",nil]; 
	    4. File's "unique identifier" on the service. 
	    	Dropbox has a "parent revision" For instance, if the Dropbox parent revision is known, 
	    	the file will be overwritten If the parent revision is unknown, a new file will be created (song (1).mp3) 
	    	(The JAFileCheckWrapper subclasses facilitate finding this value for you)
	
	*/
	
	NSMutableDictionary *fileRepresentation = [NSMutableDictionary dictionary];
	
	/*
		There are several string constants included with the project. You will need:
		JAFileUploadNameKey - For the file's name as it will appear on the service
		JAFileUploadLocalPathKey - For the file's local path on the filesystem
		JAFileUploadRemotePathKey - For the file's remote path on the service
		JAFileUploadFileIDKey - For the file's "unique identifier" on the service 
		
		It's important to note that the Dropbox subclass will use `JAFileUploadFileIDKey`. 
		There is also a `JAFileUploadPathIDKey`. `JAFileUploadFileIDKey` is used to store
		information about the specific file in question. `JAFileUploadPathIDKey` is used
		to store a unique indentifier for the file's "parent folder". Google Drive and
		Box.com both use the "parent folder id" paradigm. Dropbox doesn't care about this.
	*/
	
	[fileRepresentation setObject:@"mySong.mp3" forKey:JAFileUploadNameKey];
	[fileRepresentation setObject:@"/Path/To/Song/mySong.mp3" forKey:JAFileUploadLocalPathKey];
	NSArray *remoteSongsPath = [NSArray arrayWithObjects:@"MyMusic",@"Music",@"Songs",nil];
	[fileRepresentation setObject:remoteSongsPath forKey:JAFileUploadRemotePathKey];
	//knownParentRev is optional and does not need to be set
	//if it is not set and the file exists on Dropbox, a new file will be created
	[fileRepresentation setObject:knownParentRev forKey:JAFileUploadFileIDKey];
	
	JAUploadWrapperDropbox *wrapper = [JAUploadWrapperDropbox uploaderWithPaths:fileRepresentation progress:^(NSMutableDictionary *uploadInfo) {
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

Currently the project only has support for Google Drive, Dropbox and Box.com. I'd like to 
include wrappers for other popular services in the future. I encourage others to build and 
share their own subclasses back with the project.

### Getting Started ###

To get started, drag and drop the files you need to use into your project folder. Have XCode
 add groups for any folder references. Add them to your target. Copying to the project 
 directory is not required. You have to set up SDKs for Dropbox, Box.com and Google
 Drive independently.