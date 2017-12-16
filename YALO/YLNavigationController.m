//
//  YLNavigationController.m
//  YALO
//
//  Created by Quach Ha Chan Thanh on 8/7/16.
//  Copyright © 2016 admin. All rights reserved.
//

#import "YLNavigationController.h"

@interface YLNavigationController () <UINavigationControllerDelegate>

@end

@implementation YLNavigationController

- (UIViewController *)getRootViewController {
    // Return first viewController in stack this is rootViewController
    return self.viewControllers.firstObject;
}

- (void)pushViewControllerWithStoryboard:(UIStoryboard *)storyboard instantitalIdentifier:(NSString *)identifier  animated:(BOOL)animated {
    
    // Get Viewcontroller with instantiateViewControllerWithIdentifier in storyboard
    id pushViewController = [storyboard instantiateViewControllerWithIdentifier:identifier];
    
    // If pushViewController not null, push to navigationController
    if (pushViewController) [self pushViewController:pushViewController animated:animated];
}

- (void)removeViewControllerClass:(Class)class {
    
    // ForEach viewControllers in NavigationController
    for(id viewController in self.viewControllers) {
        // Check viewController is not rootViewControntroller and isKindOf class param
        if ([viewController isKindOfClass:class] && viewController != [self getRootViewController]) {
            
            // Convert to mutableArray and remove view controller
            NSMutableArray *viewControllerMutableArray = [self.viewControllers mutableCopy];
            [viewControllerMutableArray removeObject:viewController];
            
            self.viewControllers = viewControllerMutableArray;
        }
    }
}

- (void)popToRootViewController:(UIViewController*)controller animated:(BOOL)animated completion:(void (^)(void))completeHandler {
    
    // Convert to mutableArray
    NSMutableArray *viewControllerMutableArray = [self.viewControllers mutableCopy];
    
    // ForEach viewControllers in NavigationController
    for(id viewController in self.viewControllers) {
        // Check viewController is not rootViewControntroller and is not controller param
        if (viewController != controller && viewController != [self getRootViewController]) {
            
            [viewControllerMutableArray removeObject:viewController];
        }
    }
    
    self.viewControllers = viewControllerMutableArray;
    
    [self popViewControllerAnimated:animated];
    
    // Remove complete call completionHanlder if not null
    if (completeHandler) {
        completeHandler();
    }
}

@end
