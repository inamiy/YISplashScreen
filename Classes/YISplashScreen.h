//
//  YISplashScreen.h
//  YISplashScreen
//
//  Created by Yasuhiro Inami on 12/06/14.
//  Copyright (c) 2012年 Yasuhiro Inami. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>
#import "YISplashScreenAnimation.h"


@interface YISplashScreen : NSObject <UIAlertViewDelegate>

+ (void)show;

+ (void)hide;

+ (void)hideWithAnimation:(YISplashScreenAnimation*)animation;

+ (void)hideWithAnimation:(YISplashScreenAnimation*)animation
               completion:(void (^)(void))completion;

// convenient methods
+ (void)hideWithAnimationBlock:(YISplashScreenAnimationBlock)animationBlock;

+ (void)hideWithAnimationBlock:(YISplashScreenAnimationBlock)animationBlock
                    completion:(void (^)(void))completion;

@end
