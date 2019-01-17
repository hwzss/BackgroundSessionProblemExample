//
//  MCBackDownLoader.m
//  TestBackLoader
//
//  Created by kaifa on 2019/1/17.
//  Copyright © 2019 MC_MaoDou. All rights reserved.
//

#import "MCBackDownLoader.h"

NSNotificationName const MCBackDownLoaderPrgressUpdatedNotificationName = @"MCBackDownLoaderPrgressUpdatedNotificationName";

typedef void(^MCBackDownLoaderCompletionBlock)(void);

@implementation MCBackDownLoader

static MCBackDownLoader *loader;
+ (void)mcInitBackLoader {
    if (!loader) {
        loader = [[MCBackDownLoader alloc] init];
    }
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [self backgroundSession];
        _completionHandlerDictionary = [NSMutableDictionary dictionary];
    }
    return self;
}

+ (instancetype)shareLoader {
    return loader;
}

- (NSURLSession *)backgroundSession {
    if (!_backgroundSession) {
        NSString *identifier = @"com.MCBackDownLoader.BackgroundSession";
        NSURLSessionConfiguration* sessionConfig;
#if (defined(__IPHONE_OS_VERSION_MIN_REQUIRED) && __IPHONE_OS_VERSION_MIN_REQUIRED >= 80000)
        sessionConfig = [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:identifier];
#else
        sessionConfig = [NSURLSessionConfiguration backgroundSessionConfiguration:identifier];
#endif
        _queue = [[NSOperationQueue alloc] init];
        _queue.name = @"com.MCBackDownLoader.queue";
        _backgroundSession = [NSURLSession sessionWithConfiguration:sessionConfig
                                                delegate:self
                                           delegateQueue:_queue];
    }
    return _backgroundSession;
}

- (void)beginDownloadWithUrl:(NSString *)downloadURLString {
    NSURL *downloadURL = [NSURL URLWithString:downloadURLString];
    NSURLRequest *request = [NSURLRequest requestWithURL:downloadURL];
    [self.downloadTask cancelByProducingResumeData:^(NSData * _Nullable resumeData) {
        
    }];
    
    self.downloadTask = [self.backgroundSession downloadTaskWithRequest:request];
    [self.downloadTask resume];
}

- (void)pauseDownload {
    __weak __typeof(self) wSelf = self;
    [self.downloadTask cancelByProducingResumeData:^(NSData * resumeData) {
        __strong __typeof(wSelf) sSelf = wSelf;
        sSelf.resumeData = resumeData;
    }];
}

- (void)continueDownload {
    if (self.resumeData) {
        self.downloadTask = [self.backgroundSession downloadTaskWithResumeData:self.resumeData];
        [self.downloadTask resume];
        self.resumeData = nil;
    }
}

- (BOOL)isValideResumeData:(NSData *)resumeData {
    if (!resumeData || resumeData.length == 0) {
        return NO;
    }
    return YES;
}

#pragma mark - NSURLSessionDownloadDelegate
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location {
    NSLog(@"downloadTask:%lu didFinishDownloadingToURL:%@", (unsigned long)downloadTask.taskIdentifier, location);
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didResumeAtOffset:(int64_t)fileOffset expectedTotalBytes:(int64_t)expectedTotalBytes {
    
    NSLog(@"fileOffset:%lld expectedTotalBytes:%lld",fileOffset,expectedTotalBytes);
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite {
    
    CGFloat progress = (CGFloat)totalBytesWritten / totalBytesExpectedToWrite * 100;
    NSLog(@"downloadTask:%lu percent:%.2f%%",(unsigned long)downloadTask.taskIdentifier, progress);
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:MCBackDownLoaderPrgressUpdatedNotificationName object:@(progress) userInfo:nil];
    });
}

- (void)URLSessionDidFinishEventsForBackgroundURLSession:(NSURLSession *)session {
    NSLog(@"Background URL session %@ finished events.\n", session);
    
    if (session.configuration.identifier) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            MCBackDownLoaderCompletionBlock handler = [self.completionHandlerDictionary objectForKey:session.configuration.identifier];
            if (handler) {
                [self.completionHandlerDictionary removeObjectForKey:session.configuration.identifier];
                handler();
            }
        });
    }
}


- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {
    if (error) {
        if ([error.userInfo objectForKey:NSURLSessionDownloadTaskResumeData]) {
            NSData *resumeData = [error.userInfo objectForKey:NSURLSessionDownloadTaskResumeData];    
            self.resumeData = resumeData;
        }
    }
    
}


@end
