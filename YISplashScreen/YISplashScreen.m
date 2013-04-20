//
//  YISplashScreen.m
//  YISplashScreen
//
//  Created by Yasuhiro Inami on 12/06/14.
//  Copyright (c) 2012年 Yasuhiro Inami. All rights reserved.
//

#import "YISplashScreen.h"

#define YI_IS_4_INCH    ([UIScreen mainScreen].bounds.size.height == 568.0)

static UIViewController* __originalRootViewController = nil;
static UIWindow* __splashWindow = nil;
static CALayer* __splashLayer = nil;


@implementation YISplashScreen

+ (void)show
{
    UIWindow* window = [UIApplication sharedApplication].delegate.window;
    
    //
    // temporally disable rootViewController 
    // to avoid calling any CoreData logic while showing splash image
    //
    // (add dummy rootViewController to prevent console warning
    // "Applications are expected to have a root view controller at the end of application launch")
    //
    __originalRootViewController = window.rootViewController;
    window.rootViewController = [[UIViewController alloc] init];    // dummy
    
    // splash window
    UIWindow* splashWindow = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    splashWindow.windowLevel = UIWindowLevelStatusBar+1; 
    splashWindow.backgroundColor = [UIColor clearColor];
    splashWindow.rootViewController = [[UIViewController alloc] init];  // dummy
    
    // splash layer (portrait)
    // TODO: show/hide landscape splash image
    CALayer* splashLayer = [CALayer layer];
    if (YI_IS_4_INCH) {
        splashLayer.contents = (id)[UIImage imageNamed:@"Default-568h.png"].CGImage;
    }
    else {
        splashLayer.contents = (id)[UIImage imageNamed:@"Default.png"].CGImage;
    }
    splashLayer.frame = [UIScreen mainScreen].applicationFrame;
    
	if ([UIApplication sharedApplication].statusBarHidden == NO) {
	    CGFloat statusBarHeight = [[UIApplication sharedApplication] statusBarFrame].size.height;
        
	    splashLayer.frame = CGRectMake(0, 0, splashLayer.frame.size.width, splashLayer.frame.size.height + statusBarHeight);
        
	    CAShapeLayer *mask = [[CAShapeLayer alloc] init];
	    mask.frame = splashLayer.bounds;
	    mask.fillColor = [[UIColor blackColor] CGColor];
        
	    CGFloat x = 0;
	    CGFloat y = statusBarHeight;
	    CGFloat width = splashLayer.frame.size.width;
	    CGFloat height = splashLayer.frame.size.height - statusBarHeight;
        
	    CGMutablePathRef path = CGPathCreateMutable();
        
	    CGPathMoveToPoint(path, NULL, x, y);
	    CGPathAddLineToPoint(path, nil, x + width, y);
	    CGPathAddLineToPoint(path, nil, x + width, y + height);
	    CGPathAddLineToPoint(path, nil, x, y + height);
	    CGPathAddLineToPoint(path, nil, x, y);
	    CGPathCloseSubpath(path);
        
	    mask.path = path;
	    CGPathRelease(path);
        
	    splashLayer.mask = mask;
	}
    
    [splashWindow.layer addSublayer:splashLayer];
    
    __splashWindow = splashWindow;
    __splashLayer = splashLayer;
    
    [splashWindow makeKeyAndVisible];
}

+ (void)hide
{
    [self hideWithAnimations:NULL completion:NULL];
}

+ (void)hideWithAnimations:(YISplashScreenAnimationBlock)animations
{
    [self hideWithAnimations:animations completion:NULL];
}

+ (void)hideWithAnimations:(YISplashScreenAnimationBlock)animations
                completion:(void (^)(void))completion
{
    // use dispatch_after to prevent console warning
    // "Applications are expected to have a root view controller at the end of application launch"
    double delayInSeconds = 0.1;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        
        // restore rootViewController here
        UIWindow* window = [UIApplication sharedApplication].delegate.window;
        window.rootViewController = __originalRootViewController;
        
        // activate window to add window.rootViewController.view before animation starts
        [window makeKeyAndVisible];
        
        //
        // NOTE:
        // [CATransaction flush] (or running run loop once) is required
        // for animations-block to perform implicit/explicit transactions inside.
        // (e.g. status-bar animation)
        //
        [CATransaction flush];
        
        [CATransaction begin];
        [CATransaction setCompletionBlock:^{
            
            // clean up
            [__splashLayer removeFromSuperlayer];
            __splashLayer = nil;
            __splashWindow = nil;
            __originalRootViewController = nil;
            
            if (completion) {
                completion();
            }
        }];
        
        if (animations) {
            animations(__splashLayer, window.rootViewController.view.layer);
        }
        else {
            // default: fade out
            [CATransaction begin];
            [CATransaction setAnimationDuration:0.5];
            __splashLayer.opacity = 0;          
            [CATransaction commit];
        }
        
        [CATransaction commit];
        
    });
    
}

@end
