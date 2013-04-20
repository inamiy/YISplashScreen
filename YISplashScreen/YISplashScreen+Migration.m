//
//  YISplashScreen+Migration.m
//  YISplashScreenDemo
//
//  Created by Yasuhiro Inami on 2012/08/25.
//  Copyright (c) 2012年 Yasuhiro Inami. All rights reserved.
//

#import "YISplashScreen+Migration.h"

static UIAlertView* __confirmAlert = nil;
static UIAlertView* __completeAlert = nil;
static id __migrationDelegate = nil;

static void (^__migrationBlock)(void) = nil;
static void (^__migrationCompletionBlock)(void) = nil;


@interface YISplashScreenMigrationDelegate : NSObject <UIAlertViewDelegate>
@end


@implementation YISplashScreenMigrationDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView == __confirmAlert) {
        
        // migrating-alert
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Migrating...", nil) message:nil delegate:nil cancelButtonTitle:nil otherButtonTitles:nil];
        
        //UIActivityIndicatorView* indicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(125, 80, 30, 30)];
        UIActivityIndicatorView* indicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(125, 50, 30, 30)];
		indicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
		[alert addSubview:indicator];
		[indicator startAnimating];
        
        [alert show];
        
        // wait until alert animation finished
        [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.7]];
        
        // perform migration
        if (__migrationBlock) {
            __migrationBlock();
        }
        
        // close migrating-alert
        [alert dismissWithClickedButtonIndex:0 animated:YES];
        
        __completeAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Migration Complete", nil) message:NSLocalizedString(@"Migration Complete Message", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil];
        [__completeAlert show];
        
    }
    else if (alertView == __completeAlert) {
        
        // call after migration finished
        if (__migrationCompletionBlock) {
            __migrationCompletionBlock();
        }
        
    }
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (alertView == __completeAlert) {
        
        // clean up
        __migrationBlock = nil;
        __migrationCompletionBlock = nil;
        __migrationDelegate = nil;
        __confirmAlert = nil;
        __completeAlert = nil;
        
    }
}

@end


@implementation YISplashScreen (Migration)

+ (void)waitForMigration:(void (^)(void))migration completion:(void (^)(void))completion
{
    if (migration) {
        
        // use dispatch_after to prevent console warning (in iOS5)
        // "Applications are expected to have a root view controller at the end of application launch"
        double delayInSeconds = 0.01;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        
            __migrationBlock = migration;
            __migrationCompletionBlock = completion;
            
            __migrationDelegate = [[YISplashScreenMigrationDelegate alloc] init];
            
            // show migration confirm alert
            __confirmAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Migration Start", nil) message:NSLocalizedString(@"Migration Start Message", nil) delegate:__migrationDelegate cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil];
            [__confirmAlert show];
            
        });
        
    }
    else {
        if (completion) {
            completion();
        }
    }
}

@end
