YISplashScreen
==============

Easy splash screen + animation maker for iOS.

How to use
----------

```
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // show splash
    [YISplashScreen show];
    
    // simple fade out
    [YISplashScreen hide];
    
    return YES;
}
```

Hiding Animations
-----------------
```
// simple fade out
[YISplashScreen hide];

// cube
[YISplashScreen hideWithAnimations:[YISplashScreenAnimation cubeAnimation]];

// manually add animation
[YISplashScreen hideWithAnimations:^(CALayer* splashLayer, CALayer* rootLayer) {
    
    // splashLayer moves up
    [CATransaction begin];
    [CATransaction setAnimationDuration:0.7];
    [CATransaction setAnimationTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    
    splashLayer.position = CGPointMake(splashLayer.position.x, splashLayer.position.y-splashLayer.bounds.size.height);
    
    [CATransaction commit];
    
}];
```

CoreData Migration
------------------
By using `[YISplashScreen waitForMigration:completion:]` (optional), you can easily integrate simple UIAlertView-confirmation UI.

```
[YISplashScreen waitForMigration:^{
    
    //
    // NOTE: add CoreData migration logic here
    //
    
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                             [NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption,
                             [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
    
    [persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType
                                             configuration:nil
                                                       URL:url
                                                   options:options
                                                     error:nil];

} completion:^{
    
    [YISplashScreen hide];
    
}];
```

License
-------
YISplashScreen is available under the Beerware license.