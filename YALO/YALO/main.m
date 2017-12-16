//
//  main.m
//  YALO
//
//  Created by BaoNQ on 7/28/16.
//  Copyright © 2016 admin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"

int main(int argc, char * argv[]) {
    @autoreleasepool {
        [[NSUserDefaults standardUserDefaults] setObject:[NSArray arrayWithObjects: @"vi", nil] forKey:@"AppleLanguages"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        return UIApplicationMain(argc, argv, nil, NSStringFromClass([AppDelegate class]));
    }
}
