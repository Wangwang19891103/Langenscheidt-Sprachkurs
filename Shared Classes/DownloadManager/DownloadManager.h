//
//  DownloadManager.h
//  Langenscheidt-Sprachkurs
//
//  Created by Stefan Ueter on 13.05.16.
//  Copyright © 2016 mobilinga. All rights reserved.
//

#import <Foundation/Foundation.h>



extern NSString* const kDownloadManagerErrorDomain;

extern NSInteger const kDownloadManagerErrorNoInternet;
extern NSInteger const kDownloadManagerErrorCantConnectToServer;


@protocol DownloadManagerObserver;


@interface DownloadManager : NSObject <NSStreamDelegate, NSURLSessionDelegate, NSURLSessionDownloadDelegate> {
    
    NSDictionary* _fileDict;
    
//    CFReadStreamRef _readStream;
//    NSInputStream* _inputStream;
//    
//    NSOutputStream* _outputStream;
    
//    NSInteger _totalBytesRead;
    
    NSURLSession* _downloadSession;
    NSURLSessionDownloadTask*  _downloadTask;
    
    BOOL _downloadDidStart;
}

@property (nonatomic, strong) NSString* temporaryDownloadFilePath;

@property (nonatomic, strong) NSMutableArray* observers;

@property (nonatomic, readonly) NSInteger expectedFileSize;

@property (nonatomic, readonly) float downloadProgress;

@property (nonatomic, readonly) BOOL downloading;


+ (instancetype) instance;

- (void) downloadFileWithDictionary:(NSDictionary*) dict;

- (void) cancelDownload;

- (void) cleanUp;

- (void) addObserver:(id<DownloadManagerObserver>)observer;

- (void) removeObserver:(id<DownloadManagerObserver>)observer;

@end



@protocol DownloadManagerObserver <NSObject>

- (void) downloadManagerStartedDownloading;

- (void) downloadManagerFinishedDownloading;

- (void) downloadManagerUpdatedDownloadProgress:(float) progress;

- (void) downloadManagerAbortedDownloadWithError:(NSError*) error;

@end