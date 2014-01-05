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
