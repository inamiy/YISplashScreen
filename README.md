YISplashScreen 1.2.0
====================

Easy splash screen + animation maker for iOS5+ (including iOS7).

<img src="https://raw.github.com/inamiy/YISplashScreen/master/Screenshots/screenshot1.png" alt="ScreenShot1" width="225px" style="width:225px;" />

- `YISplashScreen` creates another UIWindow on top of status-bar so that transition will be nicer, compared to adding splash image directly on `mainWindow.rootViewController.view`.
- `animationBlock` is used to hide splash image with two arguments:
  - `splashLayer`: splash image layer
  - `rootLayer`: copy of `mainWindow.rootViewController.view.layer`

### View hierarchy before animation

- mainWindow (not visible)
    - mainWindow.rootViewController.view
- splashWindow
    - splashWindow.rootViewController.view (rotateable)
        - rootLayer (copy of mainWindow.rootViewController.view)
        - splashLayer (splash image layer)

Install via [CocoaPods](http://cocoapods.org/)
----------

```
pod 'YISplashScreen'
```

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
[YISplashScreen hideWithAnimation:[YISplashScreenAnimation cubeAnimation]];

// manually add animation
[YISplashScreen hideWithAnimationBlock:^(CALayer* splashLayer, CALayer* rootLayer) {
    
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
By using `[YISplashScreen showAndWaitForMigration:completion:]` (optional), you can easily integrate simple UIAlertView-confirmation UI.

```
[YISplashScreen showAndWaitForMigration:^{
    
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
`YISplashScreen` is available under the [Beerware](http://en.wikipedia.org/wiki/Beerware) license.

If we meet some day, and you think this stuff is worth it, you can buy me a beer in return.
