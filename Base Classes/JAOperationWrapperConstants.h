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
 JAOperationWrapperConstants.h
 */
#pragma mark -
#pragma mark Upload Keys
/*
 JAFileUploadNameKey - Used to identify the name of the file as it will appear on
the upload service, ie "autoexec.bat"
 */
extern NSString *const JAFileUploadNameKey;

/*
 JAFileUploadRemotePathKey - NSArray, with each NSString object representing a 
 folder in the path heirarchy. For example, if you were going to upload to this
 path: /My Cool App/Books/Classics/Bram Stoker
 You would need to set the array like so:
 [NSArray arrayWithObjects:@"My Cool App",@"Books",@"Classics",@"Bram Stoker"]
 */
extern NSString *const JAFileUploadRemotePathKey;

/*
 JAFileUploadLocalPathKey - Used to identify the full path of the local file
ie "/Users/home/music/track01.mp3"
 */
extern NSString *const JAFileUploadLocalPathKey;

/*
 JAFileUploadShareLinkKey - Used to store and retrieve an available shareable
link to a file on an upload service
 */
extern NSString *const JAFileUploadShareLinkKey;

/*
 JAFileUploadDateKey - Used to reference the date that a given file was uploaded
to an online service
 */
extern NSString *const JAFileUploadDateKey;

/*
 JAFileUploadServiceNameKey - Used to keep track of what service a file was 
uploaded to, ie "Dropbox"
 */
extern NSString *const JAFileUploadServiceNameKey;

/*
 JAFileUploadParentIDKey - Used to set and retrieve information about a file's parent
ie, Dropbox has a "parentRevision", Box.com has a "parent ID, Google Drive has a "parent ID"
 */
extern NSString *const JAFileUploadPathIDKey;

/*
 JAFileUploadPercentageKey - Stores an NSNumber wrapped CGFloat denoting upload progress
 */
extern NSString *const JAFileUploadPercentageKey;

/*
 JAFileUploadFileIDKey - Used to set and retrieve information about a file on a
 service that is represented by an ID. Google Drive uses a File ID
 */
extern NSString *const JAFileUploadFileIDKey;

#pragma mark -
#pragma mark Download Keys

/*
JAFileUploadNameKey - Used to identify the name of the file as it will appear on
the upload service, ie "autoexec.bat"
*/
extern NSString *const JAFileDownloadNameKey;

/*
 JAFileUploadRemotePathKey - NSArray, with each NSString object representing a
 folder in the path heirarchy. For example, if you were going to upload to this
 path: /My Cool App/Books/Classics/Bram Stoker
 You would need to set the array like so:
 [NSArray arrayWithObjects:@"My Cool App",@"Books",@"Classics",@"Bram Stoker"]
 */
extern NSString *const JAFileDownloadRemotePathKey;

/*
 JAFileUploadLocalPathKey - Used to identify the full path of the local file
 ie "/Users/home/music/track01.mp3"
 */
extern NSString *const JAFileDownloadLocalPathKey;

/*
 JAFileUploadDateKey - Used to reference the date that a given file was uploaded
 to an online service
 */
extern NSString *const JAFileDownloadDateKey;

/*
 JAFileUploadServiceNameKey - Used to keep track of what service a file was
 uploaded to, ie "Dropbox"
 */
extern NSString *const JAFileDownloadServiceNameKey;

/*
 JAFileUploadParentIDKey - Used to set and retrieve information about a file's parent
 ie, Dropbox has a "parentRevision", Box.com has a "parent ID, Google Drive has a "parent ID"
 */
extern NSString *const JAFileDownloadPathIDKey;

/*
 JAFileUploadPercentageKey - Stores an NSNumber wrapped CGFloat denoting upload progress
 */
extern NSString *const JAFileDownloadPercentageKey;

/*
 JAFileUploadFileIDKey - Used to set and retrieve information about a file on a
 service that is represented by an ID. Google Drive uses a File ID
 */
extern NSString *const JAFileDownloadFileIDKey;



