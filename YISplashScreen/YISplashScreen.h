//
//  YISplashScreen.h
//  YISplashScreen
//
//  Created by Yasuhiro Inami on 12/06/14.
//  Copyright (c) 2012年 Yasuhiro Inami. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^YISplashScreenAnimationBlock)(CALayer* splashLayer, CALayer* rootLayer);


@interface YISplashScreen : NSObject <UIAlertViewDelegate>

+ (void)show;

+ (void)hide;

+ (void)hideWithAnimations:(YISplashScreenAnimationBlock)animations;

+ (void)hideWithAnimations:(YISplashScreenAnimationBlock)animations
                completion:(void (^)(void))completion;

@end
