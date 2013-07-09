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
    splashWindow.rootViewController = [[UIViewController alloc] init];  // dummy (required in iOS6)
    
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
        
            CGFloat radius = 2.5f;
	    CGFloat x = 0;
	    CGFloat y = statusBarHeight;
	    CGFloat width = splashLayer.frame.size.width;
	    CGFloat height = splashLayer.frame.size.height - statusBarHeight;
        
            CGRect innerRect = CGRectInset(CGRectMake(0, statusBarHeight, width, height), radius, radius);
        
            CGFloat inside_right = innerRect.origin.x + innerRect.size.width;
            CGFloat outside_right = x + width;
            CGFloat inside_bottom = innerRect.origin.y + innerRect.size.height;
            CGFloat outside_bottom = y + height;
        
            CGFloat inside_top = innerRect.origin.y;
            CGFloat outside_top = y;
            CGFloat outside_left = x;
        
	    CGMutablePathRef path = CGPathCreateMutable();

            CGPathMoveToPoint(path, NULL, innerRect.origin.x, outside_top);
        
            CGPathAddLineToPoint(path, NULL, inside_right, outside_top);
            CGPathAddArcToPoint(path, NULL, outside_right, outside_top, outside_right, inside_top, radius);
            CGPathAddLineToPoint(path, NULL, outside_right, inside_bottom);
            CGPathAddArcToPoint(path, NULL,  outside_right, outside_bottom, inside_right, outside_bottom, radius);
        
            CGPathAddLineToPoint(path, NULL, innerRect.origin.x, outside_bottom);
            CGPathAddArcToPoint(path, NULL,  outside_left, outside_bottom, outside_left, inside_bottom, radius);
            CGPathAddLineToPoint(path, NULL, outside_left, inside_top);
            CGPathAddArcToPoint(path, NULL,  outside_left, outside_top, innerRect.origin.x, outside_top, radius);

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
    [self hideWithAnimation:[YISplashScreenAnimation fadeOutAnimation] completion:NULL];
}

+ (void)hideWithAnimation:(YISplashScreenAnimation*)animation
{
    [self hideWithAnimation:animation completion:NULL];
}

+ (void)hideWithAnimation:(YISplashScreenAnimation*)animation completion:(void (^)(void))completion
{
    BOOL shouldMove = animation.shouldMoveSplashLayerToMainWindowBeforeAnimation;
    
    [self _restoreRootViewControllerMovingSplashLayerToMainWindow:shouldMove];
    
    // perform hiding animation after rootViewController is ready
    // (mainly to wait for status-bar change & splashLayer moving)
    double delayInSeconds = 0.01;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [self _performAnimationBlock:animation.animationBlock completion:completion];
    });
}

+ (void)hideWithAnimationBlock:(YISplashScreenAnimationBlock)animationBlock
{
    [self hideWithAnimationBlock:animationBlock completion:NULL];
}

+ (void)hideWithAnimationBlock:(YISplashScreenAnimationBlock)animationBlock
                    completion:(void (^)(void))completion
{
    YISplashScreenAnimation* animation = [YISplashScreenAnimation animationWithBlock:animationBlock];
    
    [self hideWithAnimation:animation completion:completion];
}

#pragma mark -

#pragma mark Private

+ (void)_restoreRootViewControllerMovingSplashLayerToMainWindow:(BOOL)moving
{
    UIWindow* window = [UIApplication sharedApplication].delegate.window;
    
    if (window.rootViewController != __originalRootViewController) {
        
        window.rootViewController = __originalRootViewController;
        
        [window makeKeyAndVisible];
        
        if (moving) {
            [window.layer addSublayer:__splashLayer];
        }
    }
}

+ (void)_performAnimationBlock:(YISplashScreenAnimationBlock)animationBlock completion:(void (^)(void))completion
{
    UIWindow* window = [UIApplication sharedApplication].delegate.window;
    
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
    
    if (animationBlock) {
        animationBlock(__splashLayer, window.rootViewController.view.layer);
    }
    
    [CATransaction commit];
}

@end
