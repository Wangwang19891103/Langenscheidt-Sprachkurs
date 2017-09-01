//
//  DownloadManager.m
//  Langenscheidt-Sprachkurs
//
//  Created by Stefan Ueter on 13.05.16.
//  Copyright © 2016 mobilinga. All rights reserved.
//

#import "DownloadManager.h"
//#import "Reachability.h"
#import "ReachabilityManager.h"

//#define USERNAME        @"ftp_bbarkey@mobilinga.de"
//#define PASSWORD        @"GAU1.der"
//#define HOSTNAME        @"mobilinga.de"
//#define PORT            21
//#define DIRECTORY       @"mobilinga.de/dl/ios/g234wkl4562"  //@"dl/ios/g234wkl4562"

//#define USERNAME            @"ftp_langenscheidt@langiapservice.mobilinga.de"
//#define PASSWORD            @"tC5YeP9wHL"
//#define HOSTNAME            @"ftp.strato.com"
//#define PORT                @"21"
//#define DIRECTORY           @"english"

//#define BUFFER_SIZE     32768

#define DOWNLOAD_DIRECTORY      @"download"


#define HOSTNAME            @"http://langenscheidt-dl.mobilinga.de"




NSString* const kDownloadManagerErrorDomain = @"DownloadManagerErrorDomain";

NSInteger const kDownloadManagerErrorNoInternet = 101;
NSInteger const kDownloadManagerErrorCantConnectToServer = 102;




@implementation DownloadManager


#pragma mark - Init

+ (instancetype) instance {
    
    static DownloadManager* __instance = nil;
    
    @synchronized (self) {
        
        if (!__instance) {
            
            __instance = [[DownloadManager alloc] init];
        }
        
        return __instance;
    }
}


- (id) init {
    
    self = [super init];
    
    self.observers = [NSMutableArray array];

    [self _reset];
    
    return self;
}




#pragma mark - Public Methods

- (void) downloadFileWithDictionary:(NSDictionary *)dict {
    
    _fileDict = dict;
    
    [self _startDownload];
}


- (void) cancelDownload {
    
//    [self _closeInputStream];
//    
//    [self _closeOutputStream];
    
    [_downloadTask cancel];
    
}


- (void) cleanUp {
    
    [self _removeTemporaryDownloadFiles];
}


- (void) _reset {
    
    _temporaryDownloadFilePath = nil;
    _downloadProgress = 0;
//    _totalBytesRead = 0;
    _expectedFileSize = 0;
    _downloading = NO;
    _downloadDidStart = NO;
}




#pragma mark - Reachability

- (BOOL) _checkConnection {
    
    BOOL canConnectToInternet = [[ReachabilityManager instance] canConnectToInternet];
//    BOOL canConnectToServer = [[ReachabilityManager instance] canConnectToHost:HOSTNAME];
    BOOL canConnectToServer = YES;
    
    BOOL connectionAvailable = canConnectToInternet && canConnectToServer;
    
    
    
    // cant connect to internet
    
    if (!canConnectToInternet) {
        
        [self _handleNoInternet];
    }
    
    
    // cant connect to server
    
    else if (!canConnectToServer) {
        
        [self _handleCantConnectToServer];
    }
    
    return connectionAvailable;
}





#pragma mark - Manage Streams

- (void) _startDownload {

    BOOL connectionAvailable = [self _checkConnection];
    
    if (connectionAvailable) {
    
        [self _reset];
        
        [self _createNewTemporaryDownloadFilePath];
        
//        [self _openOutputStream];
        
//        [self _openInputStream];
        
        [self _startDownloadConnection];
    }
}


- (void) _finishDownload {
    
//    [self _closeInputStream];
//    
//    [self _closeOutputStream];
}


- (void) _startDownloadConnection {

    NSString* fileName = _fileDict[@"fileName"];
    NSURL* URL = [self _fullURLForFileName:fileName];

    _downloadSession = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:nil];
    
    _downloadTask = [_downloadSession downloadTaskWithURL:URL];
    
    [_downloadTask resume];
}


//- (void) _openInputStream {
//    
//    NSString* fileName = _fileDict[@"fileName"];
//    NSURL* URL = [self _fullURLForFileName:fileName];
//
////    NSString* userName = [USERNAME stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLHostAllowedCharacterSet]];
////    NSString* password = [PASSWORD stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLHostAllowedCharacterSet]];
//
//    NSLog(@"URL: %@", URL);
//    
//    _readStream = CFReadStreamCreateWithFTPURL(NULL, (__bridge CFURLRef) URL);
//    _inputStream = CFBridgingRelease(_readStream);
//    
//    BOOL success;
//    
//    success = CFReadStreamSetProperty(_readStream, kCFStreamPropertyFTPUserName, (__bridge CFTypeRef)(USERNAME));
//    success = CFReadStreamSetProperty(_readStream, kCFStreamPropertyFTPPassword, (__bridge CFTypeRef)(PASSWORD));
//    success = CFReadStreamSetProperty(_readStream, kCFStreamPropertyFTPFetchResourceInfo, (__bridge CFTypeRef)(@YES));
//    
//    NSAssert(success, @"");
//    
//    _inputStream.delegate = self;
//    [_inputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
//    [_inputStream open];
//    
//    _downloading = YES;
//}


//- (void) _closeInputStream {
//    
//    [_inputStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
//    _inputStream.delegate = nil;
//    [_inputStream close];
//    _inputStream = nil;
//    
//    _downloading = NO;
//}


//- (void) _openOutputStream {
//    
//    _outputStream = [NSOutputStream outputStreamToFileAtPath:_temporaryDownloadFilePath append:NO];
//    [_outputStream open];
//}
//
//
//- (void) _closeOutputStream {
//    
//    [_outputStream close];
//    _outputStream = nil;
//}




#pragma mark - NSURLSesstionDelegate, etc




//- (void) URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didResumeAtOffset:(int64_t)fileOffset expectedTotalBytes:(int64_t)expectedTotalBytes {
//    
//    if (expectedTotalBytes == NSURLSessionTransferSizeUnknown) {
//        
//        ;
//        ;
//    }
//    else {
//        
//        NSLog(@"expected: %lld", expectedTotalBytes);
//        
//        _expectedFileSize = expectedTotalBytes;
//        ;
//        ;
//    }
//    
//    [self _handleDownloadTaskStarted];
//}


- (void) URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite {
    
    if (!_downloadDidStart) {
        
        [self _handleDownloadTaskStarted];
        
        _downloadDidStart = YES;
    }
    
    
    NSLog(@"progress: %lld / %lld", totalBytesWritten, totalBytesExpectedToWrite);
    
    _downloadProgress = (float)totalBytesWritten / (float)totalBytesExpectedToWrite;
    
    [self _reportDownloadUpdatedProgress:_downloadProgress];
}


- (void) URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location {
    
    
    [self _copyDownloadedFileWithURL:location];
    
//    _temporaryDownloadFilePath = location.path;
    ;
    ;
    
}


- (void) URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {
 
    if (error) {
    
        if (error.code == NSURLErrorCancelled) {  // cancelled

            [self _handleDownloadTaskCancelled];
        }
        else {  // real error
            
            [self _handleDownloadTaskError:error];
        }
    }
    else {  // completed without error
        
        [self _handleDownloadTaskFinished];
    }
}




#pragma mark - Handle Download Task Events

- (void) _handleDownloadTaskStarted {
    
    NSLog(@"download started");
    
    [self _reportDownloadStarted];
}


//- (void) _handleDownloadTaskError:(NSError*) error {
//    
////    NSString* statusCode = [[_inputStream streamError] userInfo][(__bridge NSString*)kCFFTPStatusCodeKey];
////    
////    NSString* errorString2 = [NSString stringWithFormat:@"%@ (status code: %@)", errorString, statusCode];
////    
////    NSError* error = [NSError errorWithDomain:@"DownloadManagerError"
////                                         code:0
////                                     userInfo:@{
////                                                NSLocalizedDescriptionKey : errorString2
////                                                }];
////    
//    [self _handleDownloadTaskError:error];
//
//    
//}


- (void) _handleDownloadTaskFinished {
    
    NSLog(@"download finished");
    
    [self _reportDownloadFinished];
    
    [self _finishDownload];
    
//    [self cleanUp];
}


- (void) _handleDownloadTaskCancelled {
    
    NSLog(@"download cancelled");
    
    [self _removeTemporaryDownloadFiles];
    
    [self _reset];
}


- (void) _copyDownloadedFileWithURL:(NSURL*) url {
    
//    NSString* fileName = [url.path lastPathComponent];
//    NSString* downloadDirectory = [self _downloadsDirectory];
//    NSString* downloadedFilePath = [downloadDirectory stringByAppendingPathComponent:fileName];
    
//    _temporaryDownloadFilePath = downloadedFilePath;
    
    NSError* error;
    
    [[NSFileManager defaultManager] copyItemAtPath:url.path toPath:_temporaryDownloadFilePath error:&error];
    
    if (error) {
        
        NSLog(@"error: %@", error);
        ;
    }
}




#pragma mark - Handle Stream Events

//- (void) stream:(NSStream *)aStream handleEvent:(NSStreamEvent)eventCode {
//
//    if (aStream == _inputStream) {
//        
//        switch (eventCode) {
//            
//            case NSStreamEventOpenCompleted: {
//              
//                [self _handleInputStreamStarted];
//                
//                NSString* resourceSize = CFBridgingRelease(CFReadStreamCopyProperty(_readStream, kCFStreamPropertyFTPResourceSize));
//                _expectedFileSize = [resourceSize integerValue];
//            }
//                break;
//                
//            case NSStreamEventHasBytesAvailable: {
//                
//                [self _handleInputStreamBytesAvailable];
//            }
//                break;
//                
//            case NSStreamEventErrorOccurred: {
//                
//                [self _handleInputStreamError:@"Stream error"];
//            }
//                break;
//                
//            case NSStreamEventEndEncountered: {
//                
//                [self _handleInputStreamFinished];
//            }
//                break;
//                
//            default:
//                break;
//        }
//    }
//    
//    else if (aStream == _outputStream) {
//        
//        NSLog(@"output event code: %ld", eventCode);
//    }
//}


//- (void) _handleInputStreamStarted {
//    
//    NSLog(@"Input stream started.");
//    
//    [self _reportInputStreamStarted];
//}


//- (void) _handleInputStreamFinished {
//    
//    NSLog(@"Input stream finished.");
//    
//    [self _reportInputStreamFinished];
//}


//- (void) _handleInputStreamBytesAvailable {
//
//    NSInteger       bytesRead;
//    uint8_t         buffer[BUFFER_SIZE];
//    
////    [self updateStatus:@"Receiving"];
//    
//    // Pull some data off the network.
//    
//    bytesRead = [_inputStream read:buffer maxLength:sizeof(buffer)];
//    
//    if (bytesRead == -1) {
//    
//        [self _handleInputStreamError:@"Bytes could not be read"];
//    }
//    else if (bytesRead == 0) {
//        
////        [self stopReceiveWithStatus:nil];
//    }
//    else {
//
//        _totalBytesRead += bytesRead;
//        
//        _downloadProgress = (float)_totalBytesRead / (float)_expectedFileSize;
//
//        [self _reportInputStreamUpdatedProgress:_downloadProgress];
//        
//        
//        NSInteger   bytesWritten;
//        NSInteger   bytesWrittenSoFar;
//        
//        // Write to the file.
//        
//        bytesWrittenSoFar = 0;
//        
//        do {
//            
//            bytesWritten = [_outputStream write:&buffer[bytesWrittenSoFar] maxLength:(NSUInteger) (bytesRead - bytesWrittenSoFar)];
//            assert(bytesWritten != 0);
//            
//            if (bytesWritten == -1) {
//                
//                [self _handleOutputStreamError:@"File write error"];
//                break;
//            }
//            else {
//                
//                bytesWrittenSoFar += bytesWritten;
//            }
//            
//        } while (bytesWrittenSoFar != bytesRead);
//    }
//}


//- (void) _handleInputStreamError:(NSString*) errorString {
//    
//    NSString* statusCode = [[_inputStream streamError] userInfo][(__bridge NSString*)kCFFTPStatusCodeKey];
//    
//    NSString* errorString2 = [NSString stringWithFormat:@"%@ (status code: %@)", errorString, statusCode];
//    
//    NSError* error = [NSError errorWithDomain:@"DownloadManagerError"
//                                         code:0
//                                     userInfo:@{
//                                                NSLocalizedDescriptionKey : errorString2
//                                                }];
//    
//    [self _reportError:error];
//}


- (void) _handleOutputStreamError:(NSString*) errorString {
    
    NSLog(@"Output stream error: %@", errorString);
    
    [self _finishDownload];
    
    [self cleanUp];
}




#pragma mark - Observers

- (void) addObserver:(id<DownloadManagerObserver>)observer {
    
    NSValue* value = [NSValue valueWithNonretainedObject:observer];
    
    if (![self.observers containsObject:value]) {
        
        [self.observers addObject:value];
    }
}


- (void) removeObserver:(id<DownloadManagerObserver>)observer {
    
    [self.observers removeObject:[NSValue valueWithNonretainedObject:observer]];
}


- (void) _reportDownloadStarted {

    for (NSValue* value in self.observers) {
        
        id<DownloadManagerObserver> observer = [value nonretainedObjectValue];
        
        if ([observer respondsToSelector:@selector(downloadManagerStartedDownloading)]) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [observer downloadManagerStartedDownloading];
            });
        }
    }
}


- (void) _reportDownloadFinished {
    
    for (NSValue* value in self.observers) {
        
        id<DownloadManagerObserver> observer = [value nonretainedObjectValue];
        
        if ([observer respondsToSelector:@selector(downloadManagerFinishedDownloading)]) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [observer downloadManagerFinishedDownloading];
            });
        }
    }
}


- (void) _reportDownloadUpdatedProgress:(float) progress {
    
    for (NSValue* value in self.observers) {
        
        id<DownloadManagerObserver> observer = [value nonretainedObjectValue];
        
        if ([observer respondsToSelector:@selector(downloadManagerUpdatedDownloadProgress:)]) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [observer downloadManagerUpdatedDownloadProgress:progress];
            });
        }
    }
}


- (void) _reportDownloadAbortedWithError:(NSError*) error {
    
    for (NSValue* value in self.observers) {
        
        id<DownloadManagerObserver> observer = [value nonretainedObjectValue];
        
        if ([observer respondsToSelector:@selector(downloadManagerAbortedDownloadWithError:)]) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [observer downloadManagerAbortedDownloadWithError:error];
            });
        }
    }
}







#pragma mark - Temporary Download File

- (void) _createNewTemporaryDownloadFilePath {  // by Apple
    
    NSString*  result;
    CFUUIDRef uuid;
    CFStringRef uuidStr;
    
    uuid = CFUUIDCreate(NULL);
    assert(uuid != NULL);
    
    uuidStr = CFUUIDCreateString(NULL, uuid);
    assert(uuidStr != NULL);
    
    NSString* tempDirectory = NSTemporaryDirectory();
    
    NSString* downloadDirectory = [tempDirectory stringByAppendingPathComponent:DOWNLOAD_DIRECTORY];
    
    
    // create downloadDirectory
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:downloadDirectory isDirectory:nil]) {
     
        NSError* error;
        
        [[NSFileManager defaultManager] createDirectoryAtPath:downloadDirectory withIntermediateDirectories:YES attributes:nil error:&error];
        
        if (error) {
            
            NSLog(@"error: %@", [error description]);
            
        }
    }
    
    
    result = [downloadDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@", uuidStr]];
    assert(result != nil);
    
    CFRelease(uuidStr);
    CFRelease(uuid);
    
    _temporaryDownloadFilePath = result;
}


- (NSString*) _downloadsDirectory {
    
    NSString* tempDirectory = NSTemporaryDirectory();
    
    NSString* downloadDirectory = [tempDirectory stringByAppendingPathComponent:DOWNLOAD_DIRECTORY];
    
    return downloadDirectory;
}


- (void) _removeTemporaryDownloadFiles {
    
    NSString* downloadDirectory = [self _downloadsDirectory];

//    NSArray* cachePathArray = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
//    NSString* cacheDirectory = [cachePathArray lastObject];
    
    NSDirectoryEnumerator* enumerator = [[NSFileManager defaultManager] enumeratorAtPath:downloadDirectory];
    NSError* error = nil;
    BOOL result;
    
    NSString* file;
    
    while (file = [enumerator nextObject]) {
        
        result = [[NSFileManager defaultManager] removeItemAtPath:[downloadDirectory stringByAppendingPathComponent:file] error:&error];
        
        if (!result && error) {
            
            [self _handleError:error];
        }
    }
}





#pragma mark - Error handling

- (void) _handleError:(NSError*) error {
 
    NSLog(@"Error: %@", [error description]);
}


- (void) _reportDownloadError:(NSError*) error {
    
    [self _reportDownloadAbortedWithError:error];
    
    [self _finishDownload];
    
    [self cleanUp];
}


- (void) _handleNoInternet {
    
    NSError* error = [self _errorWithCode:kDownloadManagerErrorNoInternet];
    
    [self _reportDownloadAbortedWithError:error];
}


- (void) _handleCantConnectToServer {
    
    NSError* error = [self _errorWithCode:kDownloadManagerErrorCantConnectToServer];
    
    [self _reportDownloadAbortedWithError:error];
}


- (void) _handleDownloadTaskError:(NSError*) error {
    
    
}


- (NSError*) _errorWithCode:(NSInteger) code {
    
    NSError* error = [NSError errorWithDomain:kDownloadManagerErrorDomain
                                         code:code
                                     userInfo:nil];
    
    return error;
}





#pragma mark - Utility

- (NSURL*) _fullURLForFileName:(NSString*) fileName {
    
//    NSString* relativePath = [DIRECTORY stringByAppendingPathComponent:fileName];
//    NSString* userName = [USERNAME stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLHostAllowedCharacterSet]];
//    NSString* password = [PASSWORD stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLHostAllowedCharacterSet]];
//    
//    NSURL* URL = [NSURL URLWithString:[NSString stringWithFormat:@"ftp://%@/%@",
//            HOSTNAME,
//            relativePath
//            ]];

    NSURL* URL = [NSURL URLWithString:[NSString stringWithFormat:@"%@/%@", HOSTNAME, fileName]];
    
    return URL;
}

@end
