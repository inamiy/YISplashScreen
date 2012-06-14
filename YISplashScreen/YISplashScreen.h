//
//  YISplashScreen.h
//  YISplashScreen
//
//  Created by Yasuhiro Inami on 12/06/14.
//  Copyright (c) 2012年 Yasuhiro Inami. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface YISplashScreen : NSObject <UIAlertViewDelegate>

+ (void)show;

+ (void)hide;

+ (void)hideWithAnimations:(void (^)(CALayer* splashLayer))animations;

+ (void)hideWithAnimations:(void (^)(CALayer* splashLayer))animations
                completion:(void (^)(void))completion;

@end
