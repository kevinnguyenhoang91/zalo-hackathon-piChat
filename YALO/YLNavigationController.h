//
//  YLNavigationController.h
//  YALO
//
//  Created by Quach Ha Chan Thanh on 8/7/16.
//  Copyright © 2016 admin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YLNavigationController : UINavigationController

/**
 *  Get root ViewController in NavigationController. If NavigationController hasn't root ViewController, function will return null
 *
 *  @return The root ViewController in NavigationController
 */
- (UIViewController *)getRootViewController;

/**
 *  Push a ViewController. A ViewController instantial in storyboard with identifier.
    If Storyboard or identifier ViewController in Storyboard is not exits, will crash
 *
 *  @param storyboard The storyboard get a instantial ViewController identifier
 *  @param identifier The ViewController Identifier
 *  @param animated   The animation uses a horizontal slide transition. Has no effect if the view controller is already in the stack.
 */
- (void)pushViewControllerWithStoryboard:(UIStoryboard *)storyboard instantitalIdentifier:(NSString *)identifier animated:(BOOL)animated;

/**
 *  Remove all object is kind of class in stack NavigationController.
    This don't remove class is kind of rootViewController.
    If class is kind of topViewController in stack. This viewcontroller will pop out of stack
 *
 *  @param class The class want to remove in stack ViewControllers
 */
- (void)removeViewControllerClass:(Class)class;

/**
 *  Pop to root viewcontroller in ViewController
    This function will remove ViewControllers between rootViewController and controller param then popViewController to root and call completionHandler
    If controller param must be topViewController in NavigationController stack.
 *
 *  @param controller      The viewcontroller must be topViewController in NavigationStack
 *  @param animated        The animation uses a horizontal slide transition. Has no effect if the view controller is already in the stack.
 *  @param completeHandler The completionHandler when pop to root viewcontroller complete.
 */
- (void)popToRootViewController:(UIViewController*)controller animated:(BOOL)animated  completion:(void (^)(void))completeHandler;



@end
