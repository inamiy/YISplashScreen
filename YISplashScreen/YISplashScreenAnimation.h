//
//  YISplashScreenAnimation.h
//  YISplashScreen
//
//  Created by Yasuhiro Inami on 12/06/15.
//  Copyright (c) 2012年 Yasuhiro Inami. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YISplashScreen.h"


@interface YISplashScreenAnimation : NSObject

+ (YISplashScreenAnimationBlock)pageCurlAnimation;

// FIXME: cubeAnimation doesn't work when not migrating
+ (YISplashScreenAnimationBlock)cubeAnimation;

@end
