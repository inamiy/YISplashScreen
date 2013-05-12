//
//  AppDelegate.m
//  YISplashScreenDemo
//
//  Created by Yasuhiro Inami on 12/06/14.
//  Copyright (c) 2012年 Yasuhiro Inami. All rights reserved.
//

#import "AppDelegate.h"

#import "YISplashScreen.h"
#import "YISplashScreen+Migration.h" // optional
#import "YISplashScreenAnimation.h"

#define SHOWS_MIGRATION_ALERT   1
#define USES_PRESET_ANIMATION   1

@implementation AppDelegate

@synthesize window = _window;

#pragma mark -

#pragma mark UIApplicationDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // show splash
    [YISplashScreen show];
    
#if SHOWS_MIGRATION_ALERT
    void (^migrationBlock)(void) = ^{
        sleep(1);   // NOTE: add CoreData migration logic here
    };
#else
    void (^migrationBlock)(void) = nil;
#endif
    
    [YISplashScreen waitForMigration:migrationBlock completion:^{
        
        [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
        
#if USES_PRESET_ANIMATION == 1
        
        //--------------------------------------------------
        // fade out
        //--------------------------------------------------
//        [YISplashScreen hide];    // fadeOutAnimation
//        [YISplashScreen hideWithAnimation:[YISplashScreenAnimation fadeOutAnimation]]
        
        //--------------------------------------------------
        // page curl
        //--------------------------------------------------
//        [YISplashScreen hideWithAnimation:[YISplashScreenAnimation pageCurlAnimation]];
        
        //--------------------------------------------------
        // cube
        //--------------------------------------------------
        [YISplashScreen hideWithAnimation:[YISplashScreenAnimation cubeAnimation]];
        
        //--------------------------------------------------
        // circle wipe
        //--------------------------------------------------
//        [YISplashScreen hideWithAnimation:[YISplashScreenAnimation circleOpeningAnimation]];
//        [YISplashScreen hideWithAnimation:[YISplashScreenAnimation circleClosingAnimation]];
        
#else
        // manual
        [YISplashScreen hideWithAnimationBlock:^(CALayer* splashLayer, CALayer* rootLayer) {
            
            [CATransaction begin];
            [CATransaction setAnimationDuration:0.7];
            [CATransaction setAnimationTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
            
            splashLayer.position = CGPointMake(splashLayer.position.x, splashLayer.position.y-splashLayer.bounds.size.height);
            
            [CATransaction commit];
        }];
#endif
        
    }];
    
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
