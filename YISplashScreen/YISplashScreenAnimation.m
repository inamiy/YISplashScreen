//
//  YISplashScreenAnimation.m
//  YISplashScreen
//
//  Created by Yasuhiro Inami on 12/06/15.
//  Copyright (c) 2012年 Yasuhiro Inami. All rights reserved.
//

#import "YISplashScreenAnimation.h"
#import <QuartzCore/QuartzCore.h>

static inline CATransform3D CATransform3DMakePerspective(CGFloat z)
{
    CATransform3D t = CATransform3DIdentity;
    t.m34 = - 1.0 / z;
    return t;
}


@implementation YISplashScreenAnimation

+ (YISplashScreenAnimationBlock)pageCurlAnimation
{
    YISplashScreenAnimationBlock animationBlock = ^(CALayer* splashLayer, CALayer* rootLayer) {
		
        // adjust anchorPoint
        [CATransaction begin];
        [CATransaction setDisableActions:YES];
        
        splashLayer.anchorPoint = CGPointMake(-0.0, 0.5);
        splashLayer.position = CGPointMake(splashLayer.bounds.size.width*splashLayer.anchorPoint.x, splashLayer.bounds.size.height*splashLayer.anchorPoint.y);
        
        [CATransaction commit];
        
        // page-curl effect
        CATransform3D transform = CATransform3DMakePerspective(800.0);
        
        CATransform3D transform1 = CATransform3DRotate(transform, -M_PI_2/10, 0, 1, 0);
        CATransform3D transform2 = CATransform3DRotate(transform, -M_PI_2, 0, 1, 0);
        
        CAKeyframeAnimation* keyframeAnimation = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
        keyframeAnimation.duration = 2;
        keyframeAnimation.values = [NSArray arrayWithObjects:
                                    [NSValue valueWithCATransform3D:transform],
                                    [NSValue valueWithCATransform3D:transform1], 
                                    [NSValue valueWithCATransform3D:transform2],
                                    nil]; 
        keyframeAnimation.keyTimes = [NSArray arrayWithObjects:
                                      [NSNumber numberWithFloat:0], 
                                      [NSNumber numberWithFloat:.2], 
                                      [NSNumber numberWithFloat:1.0], 
                                      nil]; 
        keyframeAnimation.timingFunctions = [NSArray arrayWithObjects:
                                             [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut],
                                             [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn], 
                                             nil];
        keyframeAnimation.removedOnCompletion = NO;
        keyframeAnimation.fillMode = kCAFillModeForwards;
        [splashLayer addAnimation:keyframeAnimation forKey:@"pageCurlAnimation"];
        
	};
    
    return [animationBlock copy];
}

+ (YISplashScreenAnimationBlock)cubeAnimation
{
    YISplashScreenAnimationBlock animationBlock = ^(CALayer* splashLayer, CALayer* rootLayer) {
        
        CATransform3D perspective = CATransform3DMakePerspective(800.0);
        
        CALayer* windowLayer = rootLayer.superlayer;
        CGFloat halfWidth = rootLayer.frame.size.width/2;
        
        // move splash & root layers to transformLayer
        CATransformLayer* transformLayer = [CATransformLayer layer];
        transformLayer.frame = rootLayer.bounds;
        [splashLayer removeFromSuperlayer];
        [rootLayer removeFromSuperlayer];
        [transformLayer addSublayer:splashLayer];
        [transformLayer addSublayer:rootLayer];
        [windowLayer addSublayer:transformLayer];
        
        // transform rootLayer to right-hand-side
        [CATransaction begin];
        [CATransaction setDisableActions:YES];

        CATransform3D transform = CATransform3DIdentity;
        transform = CATransform3DTranslate(transform, 0, 0, -halfWidth);
        transform = CATransform3DRotate(transform, M_PI_2, 0, 1, 0);
        transform = CATransform3DTranslate(transform, 0, 0, halfWidth);
        
        rootLayer.transform = transform;

        [CATransaction commit];
        
        // transformLayer rotation
        [CATransaction begin];
        [CATransaction setCompletionBlock:^{
            rootLayer.transform = CATransform3DIdentity;
            [windowLayer addSublayer:rootLayer];
            [transformLayer removeFromSuperlayer];
        }];

        CABasicAnimation *transformAnimation = [CABasicAnimation animationWithKeyPath:@"transform"];
        transformAnimation.duration = 0.75;
        
        transform = perspective;
        transformAnimation.fromValue = [NSValue valueWithCATransform3D:transform];
        
        transform = CATransform3DTranslate(transform, 0, 0, -halfWidth);
        transform = CATransform3DRotate(transform, -M_PI_2, 0, 1, 0);
        transform = CATransform3DTranslate(transform, 0, 0, halfWidth);
        transformAnimation.toValue = [NSValue valueWithCATransform3D:transform];
        
        [transformLayer addAnimation:transformAnimation forKey:@"cubeAnimation"];
        transformLayer.transform = transform;
        
        [CATransaction commit];
    };
    
    return [animationBlock copy];
}

@end
