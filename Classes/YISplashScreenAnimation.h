//
//  YISplashScreenAnimation.h
//  YISplashScreen
//
//  Created by Yasuhiro Inami on 12/06/15.
//  Copyright (c) 2012年 Yasuhiro Inami. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>

typedef void (^YISplashScreenAnimationBlock)(CALayer* splashLayer, CALayer* rootLayer);


@interface YISplashScreenAnimation : NSObject

@property (nonatomic, copy) YISplashScreenAnimationBlock animationBlock;

//
// Tells YISplashScreen to move splashLayer from splashWindow (above status-bar)
// to mainWindow (below status-bar) before animation starts.
// Set to YES whenever animationBlock handles splashLayer as such,
// or layer-flickering may occur inside the block.
// See 'cubeAnimation' for more detail. Default is NO.
//
@property (nonatomic) BOOL shouldMoveSplashLayerToMainWindowBeforeAnimation;

+ (instancetype)animationWithBlock:(YISplashScreenAnimationBlock)animationBlock;

// presets
+ (instancetype)fadeOutAnimation;
+ (instancetype)pageCurlAnimation;
+ (instancetype)cubeAnimation;
+ (instancetype)circleOpeningAnimation;
+ (instancetype)circleClosingAnimation;

// WARNING: uses private APIs
+ (instancetype)_blurredCircleOpeningAnimation;
+ (instancetype)_blurredCircleClosingAnimation;

@end
