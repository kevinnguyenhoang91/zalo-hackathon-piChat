//
//  GroupSettingViewController.h
//  YALO
//
//  Created by BaoNQ on 8/4/16.
//  Copyright © 2016 admin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YLGroupChat.h"

#define kGroupSettingTitleFont [UIFont fontWithName:@"Avenir" size:17.0]

@interface GroupSettingViewController : UIViewController

@property (nonatomic, weak) YLGroupChat *groupInfo;

@end
