//
//  YISplashScreen+Migration.h
//  YISplashScreenDemo
//
//  Created by Yasuhiro Inami on 2012/08/25.
//  Copyright (c) 2012年 Yasuhiro Inami. All rights reserved.
//

#import "YISplashScreen.h"

@interface YISplashScreen (Migration)

// simple UIAlertView-confirmation on migration
+ (void)waitForMigration:(void (^)(void))migration completion:(void (^)(void))completion;

@end
