//
//  YISplashScreenAnimation.m
//  YISplashScreen
//
//  Created by Yasuhiro Inami on 12/06/15.
//  Copyright (c) 2012年 Yasuhiro Inami. All rights reserved.
//

#import "YISplashScreenAnimation.h"

static inline CATransform3D CATransform3DMakePerspective(CGFloat z)
{
    CATransform3D t = CATransform3DIdentity;
    t.m34 = - 1.0 / z;
    return t;
}


@implementation YISplashScreenAnimation

+ (instancetype)animationWithBlock:(YISplashScreenAnimationBlock)animationBlock
{
    YISplashScreenAnimation* animation = [[YISplashScreenAnimation alloc] init];
    animation.animationBlock = animationBlock;
    
    return animation;
}

#pragma mark -

#pragma mark Presets

+ (instancetype)fadeOutAnimation
{
    YISplashScreenAnimationBlock animationBlock = ^(CALayer* splashLayer, CALayer* rootLayer) {
        [CATransaction begin];
        [CATransaction setAnimationDuration:0.5];
        splashLayer.opacity = 0;
        [CATransaction commit];
    };
    
    YISplashScreenAnimation* animation = [YISplashScreenAnimation animationWithBlock:animationBlock];
    
    return animation;
}

+ (instancetype)pageCurlAnimation
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
    
    YISplashScreenAnimation* animation = [YISplashScreenAnimation animationWithBlock:animationBlock];
    
    return animation;
}

+ (instancetype)cubeAnimation
{
    YISplashScreenAnimationBlock animationBlock = ^(CALayer* splashLayer, CALayer* rootLayer) {
        
        CATransform3D perspective = CATransform3DMakePerspective((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) ? 1600: 800);
        
        CALayer* superlayer = rootLayer.superlayer;
        CGFloat halfWidth = rootLayer.frame.size.width/2;
        
        // create transformLayer & move splash + root layers to transformLayer
        CATransformLayer* transformLayer = [CATransformLayer layer];
        transformLayer.frame = rootLayer.bounds;
        [transformLayer addSublayer:rootLayer];
        [transformLayer addSublayer:splashLayer];
        [superlayer addSublayer:transformLayer];
        
        // set rootLayer to right-hand-side
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
            [superlayer addSublayer:rootLayer];
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
    
    YISplashScreenAnimation* animation = [YISplashScreenAnimation animationWithBlock:animationBlock];
    
    return animation;
}

+ (instancetype)circleOpeningAnimation
{
    return [self _circleWipeAnimationWithOpening:YES];
}

+ (instancetype)circleClosingAnimation
{
    return [self _circleWipeAnimationWithOpening:NO];
}

+ (instancetype)_circleWipeAnimationWithOpening:(BOOL)opening
{
    YISplashScreenAnimationBlock animationBlock = ^(CALayer* splashLayer, CALayer* rootLayer) {
		
        CGFloat w = splashLayer.bounds.size.width/2;
        CGFloat h = splashLayer.bounds.size.height/2;
        CGFloat d = sqrt(w*w+h*h);  // distance from corner to center
        
        CGRect largeRect = CGRectMake(w-d, h-d, 2*d, 2*d);
        CGRect zeroRect = CGRectMake(splashLayer.bounds.size.width/2, splashLayer.bounds.size.height/2, 0, 0);
        
        UIBezierPath* fromPath;
        UIBezierPath* toPath;
        
        if (opening) {
            UIBezierPath* fromPath1 = [UIBezierPath bezierPathWithOvalInRect:zeroRect];
            UIBezierPath* toPath1 = [UIBezierPath bezierPathWithOvalInRect:largeRect];
            
            fromPath = [UIBezierPath bezierPathWithOvalInRect:largeRect];
            [fromPath appendPath:fromPath1];
            
            toPath = [UIBezierPath bezierPathWithOvalInRect:largeRect];
            [toPath appendPath:toPath1];
        }
        else {
            fromPath = [UIBezierPath bezierPathWithOvalInRect:largeRect];
            toPath = [UIBezierPath bezierPathWithOvalInRect:zeroRect];
        }
        
        CAShapeLayer *mask = [[CAShapeLayer alloc] init];
        mask.frame = splashLayer.bounds;
        mask.fillColor = [[UIColor blackColor] CGColor];
        mask.fillRule = kCAFillRuleEvenOdd;
        splashLayer.mask = mask;
        
        CABasicAnimation* animation = [CABasicAnimation animationWithKeyPath:@"path"];
        animation.duration = 0.75;
        animation.repeatCount = 1;
        animation.removedOnCompletion = NO;
        animation.fillMode = kCAFillModeForwards;
        animation.fromValue = (__bridge id)fromPath.CGPath;
        animation.toValue = (__bridge id)toPath.CGPath;
        [mask addAnimation:animation forKey:@"circleWipeAnimation"];
        
	};
    
    YISplashScreenAnimation* animation = [YISplashScreenAnimation animationWithBlock:animationBlock];
    
    return animation;
}

+ (instancetype)_blurredCircleOpeningAnimation
{
    return [self _blurredCircleWipeAnimationWithOpening:YES];
}

+ (instancetype)_blurredCircleClosingAnimation
{
    return [self _blurredCircleWipeAnimationWithOpening:NO];
}

+ (instancetype)_blurredCircleWipeAnimationWithOpening:(BOOL)opening
{
    YISplashScreenAnimationBlock animationBlock = ^(CALayer* splashLayer, CALayer* rootLayer) {
		
        CGFloat max, min;
        if (splashLayer.bounds.size.width > splashLayer.bounds.size.height) {
            max = splashLayer.bounds.size.width;
            min = splashLayer.bounds.size.height;
        }
        else {
            min = splashLayer.bounds.size.width;
            max = splashLayer.bounds.size.height;
        }
        
        CGFloat maxEndPoint = 0.5*(1+sqrt(2));
        
        CAGradientLayer *mask = [CAGradientLayer layer];
        mask.anchorPoint = CGPointZero;
        mask.startPoint = CGPointMake(0.5, 0.5);
        mask.endPoint = CGPointMake(maxEndPoint, maxEndPoint);
        
        // WARNING: kCAGradientLayerRadial (private API) 
        mask.type = @"radial";
        
        // set large radial mask to fit whole splashLayer & translate startPoint to center
        mask.bounds = CGRectMake(0, 0, max, max);
        mask.transform = CATransform3DMakeTranslation((min-max)/2, 0, 0);
        
        splashLayer.mask = mask;
        
        UIColor *maskColor = [UIColor colorWithWhite:1.0 alpha:0.0];
        UIColor *noMaskColor = [UIColor colorWithWhite:1.0 alpha:1.0];
        
        NSArray* zeroLocations = @[@0.0, @0.0, @0.0];
        NSArray* enlargedLocations = @[@0.0, @0.9, @1.0];
        
        NSArray* toValue;
        
        if (opening) {
            mask.colors = @[(id)maskColor.CGColor, (id)maskColor.CGColor, (id)noMaskColor.CGColor];
            mask.locations = zeroLocations;
            toValue = enlargedLocations;
        }
        else {
            mask.colors = @[(id)noMaskColor.CGColor, (id)noMaskColor.CGColor, (id)maskColor.CGColor];
            mask.locations = enlargedLocations;
            toValue = zeroLocations;
        }
        
        CABasicAnimation* animation = [CABasicAnimation animationWithKeyPath:@"locations"];
        animation.duration = 0.75;
        animation.repeatCount = 1;
        animation.removedOnCompletion = NO;
        animation.fillMode = kCAFillModeForwards;
        animation.toValue = toValue;
        [mask addAnimation:animation forKey:@"_blurredCircleWipeAnimation"];
        
	};
    
    YISplashScreenAnimation* animation = [YISplashScreenAnimation animationWithBlock:animationBlock];
    
    return animation;
}

@end
