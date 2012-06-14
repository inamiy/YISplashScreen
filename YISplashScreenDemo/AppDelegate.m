//
//  AppDelegate.m
//  YISplashScreenDemo
//
//  Created by Yasuhiro Inami on 12/06/14.
//  Copyright (c) 2012年 Yasuhiro Inami. All rights reserved.
//

#import "AppDelegate.h"
#import "YISplashScreen.h"
#import "YISplashScreenAnimation.h"

#define SHOWS_MIGRATION_ALERT   0   // 0 or 1
#define ANIMATION_TYPE          2   // 0-2

@implementation AppDelegate

@synthesize window = _window;

- (void)startApp
{
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
    
#if ANIMATION_TYPE == 0
    
    // simple fade out
    [YISplashScreen hide];
    
#elif ANIMATION_TYPE == 1
    
    // manual
    [YISplashScreen hideWithAnimations:^(CALayer* splashLayer) {
        [CATransaction begin];
        [CATransaction setAnimationDuration:0.7];
         [CATransaction setAnimationTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
        [CATransaction setCompletionBlock:^{
            
        }];
        
        splashLayer.position = CGPointMake(splashLayer.position.x, splashLayer.position.y-splashLayer.bounds.size.height);
        
        [CATransaction commit];
    }];

#else
    
    // page curl
    [YISplashScreen hideWithAnimations:[YISplashScreenAnimation pageCurlAnimation]];
    
#endif
    
}

#pragma mark -

#pragma mark UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView == _confirmAlert) {
        
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Migrating..." message:@"Please wait..." delegate:nil cancelButtonTitle:nil otherButtonTitles:nil];
        [alert show];
        
        //
        // NOTE: add CoreData migration logic here
        //
        
        double delayInSeconds = 2.0;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            
            [alert dismissWithClickedButtonIndex:0 animated:YES];
            
            _completeAlert = [[UIAlertView alloc] initWithTitle:@"Migration Complete" message:@"Test is complete." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [_completeAlert show];
        });
        
    }
    else if (alertView == _completeAlert) {
        
        // call after migration finished
        [self startApp];
        
    }
}

#pragma mark -

#pragma mark UIApplicationDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // show splash
    [YISplashScreen show];
    
#if SHOWS_MIGRATION_ALERT
    
    // show migration confirm alert
    _confirmAlert = [[UIAlertView alloc] initWithTitle:@"Migration Start" message:@"This is test." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [_confirmAlert show];
    
#else
    
    // start app immediately
    [self startApp];
    
#endif
    
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
