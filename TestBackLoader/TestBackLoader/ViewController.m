//
//  ViewController.m
//  TestBackLoader
//
//  Created by kaifa on 2019/1/17.
//  Copyright © 2019 MC_MaoDou. All rights reserved.
//

#import "ViewController.h"
#import "MCBackDownLoader.h"

@interface ViewController ()

@property (strong, nonatomic) IBOutlet UIProgressView *downloadProgress;
@property (weak, nonatomic) IBOutlet UILabel *progressLabel;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIKIT_EXTERN NSNotificationName const MCBackDownLoaderPrgressUpdatedNotificationName;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_MCBackDownLoaderPrgressUpdatedNotificationName:) name:MCBackDownLoaderPrgressUpdatedNotificationName object:nil];
  
}

- (void)_MCBackDownLoaderPrgressUpdatedNotificationName:(NSNotification *)notification  {
    CGFloat fProgress = [(NSNumber *)notification.object floatValue];
    self.progressLabel.text = [NSString stringWithFormat:@"%.2f%%",fProgress * 100];
    self.downloadProgress.progress = fProgress;
}

- (void)updateDownloadProgress:(NSNotification *)notification {
    NSDictionary *userInfo = notification.userInfo;
    CGFloat fProgress = [userInfo[@"progress"] floatValue];
    self.progressLabel.text = [NSString stringWithFormat:@"%.2f%%",fProgress * 100];
    self.downloadProgress.progress = fProgress;
}

#pragma mark Method
- (IBAction)download:(id)sender {
    
    // TODO: here, you should gvie a right file url
    [[MCBackDownLoader shareLoader] beginDownloadWithUrl:@"http://192.168.199.108:4567/demofile"];
}

- (IBAction)pauseDownlaod:(id)sender {
    [[MCBackDownLoader shareLoader] pauseDownload];
}

- (IBAction)continueDownlaod:(id)sender {
    [[MCBackDownLoader shareLoader] continueDownload];
}


@end
