//
//  YISplashScreenAnimation.m
//  YISplashScreen
//
//  Created by Yasuhiro Inami on 12/06/15.
//  Copyright (c) 2012年 Yasuhiro Inami. All rights reserved.
//

#import "YISplashScreenAnimation.h"

@implementation YISplashScreenAnimation


#pragma mark -

#pragma mark Hiding Animations

+ (id)pageCurlAnimation
{
    void(^animationBlock)(CALayer*) = ^(CALayer* splashLayer) {
		
        // adjust anchorPoint
        [CATransaction begin];
        [CATransaction setDisableActions:YES];
        splashLayer.anchorPoint = CGPointMake(-0.0, 0.5);
        splashLayer.position = CGPointMake(splashLayer.bounds.size.width*splashLayer.anchorPoint.x, splashLayer.bounds.size.height*splashLayer.anchorPoint.y);
        [CATransaction commit];
        
        // page-curl effect
        CATransform3D transform = CATransform3DIdentity;
        float zDistanse = 800.0;
        transform.m34 = 1.0 / -zDistanse;
        
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
        [splashLayer addAnimation:keyframeAnimation forKey:nil];
        
	};
    
    return [animationBlock copy];
}

@end
