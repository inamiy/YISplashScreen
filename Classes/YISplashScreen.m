//
//  YISplashScreen.m
//  YISplashScreen
//
//  Created by Yasuhiro Inami on 12/06/14.
//  Copyright (c) 2012年 Yasuhiro Inami. All rights reserved.
//

#import "YISplashScreen.h"

#define IS_IPAD                 (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
#define IS_PORTRAIT             UIInterfaceOrientationIsPortrait([UIApplication sharedApplication].statusBarOrientation)
#define IS_4_INCH               ([UIScreen mainScreen].bounds.size.height == 568.0)
#define IS_IOS_AT_LEAST(ver)    ([[[UIDevice currentDevice] systemVersion] compare:ver] != NSOrderedAscending)

#if defined(__IPHONE_7_0) && __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_7_0
#define IS_FLAT_DESIGN          IS_IOS_AT_LEAST(@"7.0")
#else
#define IS_FLAT_DESIGN          NO
#endif

static UIViewController* __originalRootViewController = nil;
static UIWindow* __splashWindow = nil;
static CALayer* __splashLayer = nil;
static CALayer* __copiedRootLayer = nil;


@interface _YISplashScreenViewController : UIViewController

@property (nonatomic) BOOL rotationEnabled;

@end


@implementation _YISplashScreenViewController

- (id)init
{
    self = [super init];
    if (self) {
        _rotationEnabled = YES;
    }
    return self;
}

- (BOOL)shouldAutorotate
{
    return _rotationEnabled;
}

@end


@implementation YISplashScreen

+ (UIImage*)_preferredSplashImage
{
    UIImage* splashImage = nil;
    
    //
    // Xcode4 Default.png filenames:
    // https://developer.apple.com/library/ios/DOCUMENTATION/iPhone/Conceptual/iPhoneOSProgrammingGuide/App-RelatedResources/App-RelatedResources.html#//apple_ref/doc/uid/TP40007072-CH6-SW12
    //
    if (!splashImage) {
        NSMutableString* imageName = @"Default".mutableCopy;
        
        if (IS_4_INCH) {
            [imageName appendString:@"-568h"];
        }
        else if (IS_IPAD) {
            if (IS_PORTRAIT) {
                [imageName appendString:@"-Portrait"];
            }
            else {
                [imageName appendString:@"-Landscape"];
            }
        }
        
        splashImage = [UIImage imageNamed:imageName];
    }
    
    //
    // Xcode5 AssetCatalog LaunchImage filenames:
    // http://stackoverflow.com/questions/19107543/xcode-5-asset-catalog-how-to-reference-the-launchimage
    //
    if (!splashImage) {
        NSMutableString* imageName = @"LaunchImage".mutableCopy;
        
        if (IS_FLAT_DESIGN) {
            [imageName appendString:@"-700"];
        }
        if (IS_4_INCH) {
            [imageName appendString:@"-568h"];
        }
        else if (IS_IPAD) {
            if (IS_PORTRAIT) {
                [imageName appendString:@"-Portrait"];
            }
            else {
                [imageName appendString:@"-Landscape"];
            }
        }
        
        splashImage = [UIImage imageNamed:imageName];
    }
    
    return splashImage;
}

+ (BOOL)_hidesStatusBarDuringAppLaunch
{
    return [[[NSBundle mainBundle] objectForInfoDictionaryKey:@"UIStatusBarHidden"] boolValue];
}

+ (void)show
{
    UIWindow* splashWindow = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    splashWindow.backgroundColor = [UIColor blackColor];    // set black to not show mainWindow
    
    _YISplashScreenViewController* splashRootVC = [[_YISplashScreenViewController alloc] init];
    splashRootVC.view.backgroundColor = [UIColor clearColor];
    splashWindow.rootViewController = splashRootVC;
    
    CALayer* splashLayer = [CALayer layer];
    UIImage* splashImage = [self _preferredSplashImage];
    splashLayer.contents = (id)splashImage.CGImage;
    [splashRootVC.view.layer addSublayer:splashLayer];
    
    [splashWindow makeKeyAndVisible];
    
    // adjust frame after makeKeyAndVisible (splashRootVC.view is ready)
    splashLayer.frame = CGRectMake(0,
                                   splashRootVC.view.bounds.size.height-splashImage.size.height,  // mostly 0 or -20
                                   splashImage.size.width,
                                   splashImage.size.height);
    
    if ([self _hidesStatusBarDuringAppLaunch]) {
        // above statusBar (will be set to UIWindowLevelStatusBar-1 on hide)
        splashWindow.windowLevel = UIWindowLevelStatusBar+1;
    }
    else {
        // below statusBar
        splashWindow.windowLevel = UIWindowLevelStatusBar-1;
    }
    
    __splashWindow = splashWindow;
    __splashLayer = splashLayer;
    
    // lock rotation while showing
    splashRootVC.rotationEnabled = NO;
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
    [self _prepareForAnimation];
    
    // perform hiding animation after iOS7-fading animation finished
    double delayInSeconds = IS_IOS_AT_LEAST(@"7.0") ? 0.5 : 0;
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

+ (void)_prepareForAnimation
{
    [self attachRootViewController];
    
    // temporarily switch mainWindow to create rootViewController.view
    UIWindow* mainWindow = [UIApplication sharedApplication].delegate.window;
    [mainWindow makeKeyAndVisible];
    [__splashWindow makeKeyAndVisible];
    
    // move below statusBar
    __splashWindow.windowLevel = UIWindowLevelStatusBar-1;
    
    UIView* mainRootView = mainWindow.rootViewController.view;
    
    // create rootView snapshot
    UIGraphicsBeginImageContextWithOptions(mainRootView.bounds.size, NO, 0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    if ([mainRootView respondsToSelector:@selector(drawViewHierarchyInRect:afterScreenUpdates:)]) {
#if defined(__IPHONE_7_0) && __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_7_0
        // tints tabBar-background in iOS7
        [mainRootView drawViewHierarchyInRect:mainRootView.bounds afterScreenUpdates:YES];
#endif
    }
    else {
        CALayer* rootLayer = mainRootView.layer;
        CGContextRef context = UIGraphicsGetCurrentContext();
        // doesn't tint tabBar-background in iOS7
        [rootLayer renderInContext:context];
    }
    UIImage* rootLayerImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    CALayer* copiedRootLayer = [CALayer layer];
    copiedRootLayer.frame = [mainRootView convertRect:mainRootView.bounds toView:__splashWindow.rootViewController.view];
    
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    copiedRootLayer.contents = (id)rootLayerImage.CGImage;
    [__splashWindow.rootViewController.view.layer insertSublayer:copiedRootLayer atIndex:0];
    [CATransaction commit];
    
    __copiedRootLayer = copiedRootLayer;
}

+ (void)_performAnimationBlock:(YISplashScreenAnimationBlock)animationBlock completion:(void (^)(void))completion
{
    [CATransaction begin];
    [CATransaction setCompletionBlock:^{
        
        // clean up
        [__copiedRootLayer removeFromSuperlayer];
        __copiedRootLayer = nil;
        [__splashLayer removeFromSuperlayer];
        __splashLayer = nil;
        __splashWindow = nil;
        __originalRootViewController = nil;
        
        UIWindow* mainWindow = [UIApplication sharedApplication].delegate.window;
        [mainWindow makeKeyAndVisible];
        
        if (completion) {
            completion();
        }
    }];
    
    if (animationBlock) {
        animationBlock(__splashLayer, __copiedRootLayer);
    }
    
    [CATransaction commit];
}

@end


#pragma mark -


@implementation YISplashScreen (RootDetaching)

+ (void)detachRootViewController
{
    if (!__originalRootViewController) {
        
        UIWindow* mainWindow = [UIApplication sharedApplication].delegate.window;
        __originalRootViewController = mainWindow.rootViewController;
        
        // add dummy rootViewController to prevent console warning
        // "Applications are expected to have a root view controller at the end of application launch".
        mainWindow.rootViewController = [[UIViewController alloc] init];
        
    }
}

+ (void)attachRootViewController
{
    if (__originalRootViewController) {
        UIWindow* mainWindow = [UIApplication sharedApplication].delegate.window;
        mainWindow.rootViewController = __originalRootViewController;
    }
}

@end
