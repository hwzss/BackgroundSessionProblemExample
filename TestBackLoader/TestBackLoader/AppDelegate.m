//
//  AppDelegate.m
//  TestBackLoader
//
//  Created by kaifa on 2019/1/17.
//  Copyright © 2019 MC_MaoDou. All rights reserved.
//

#import "AppDelegate.h"
#import "MCBackDownLoader.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [MCBackDownLoader mcInitBackLoader];
    return YES;
}

- (void)application:(UIApplication *)application handleEventsForBackgroundURLSession:(NSString *)identifier completionHandler:(void (^)(void))completionHandler {
    [[MCBackDownLoader shareLoader].completionHandlerDictionary setObject:completionHandler forKey:identifier];
}

@end
