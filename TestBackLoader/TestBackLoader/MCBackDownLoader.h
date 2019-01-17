//
//  MCBackDownLoader.h
//  TestBackLoader
//
//  Created by kaifa on 2019/1/17.
//  Copyright © 2019 MC_MaoDou. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface MCBackDownLoader : NSObject <NSURLSessionDownloadDelegate>

@property (strong, nonatomic) NSMutableDictionary *completionHandlerDictionary;
@property (strong, nonatomic) NSURLSessionDownloadTask *downloadTask;
@property (strong, nonatomic) NSURLSession *backgroundSession;
@property (strong, nonatomic) NSOperationQueue *queue;
@property (strong, nonatomic, nullable) NSData *resumeData;

+ (void)mcInitBackLoader;
+ (instancetype)shareLoader;

- (void)beginDownloadWithUrl:(NSString *)downloadURLString;
- (void)pauseDownload;
- (void)continueDownload;
@end

NS_ASSUME_NONNULL_END
