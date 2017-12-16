//
//  YLGroupSettingCell.m
//  YALO/Users/admin/Desktop/Git/YALO/YALO/YLGroupSettingCell.m
//
//  Created by BaoNQ on 8/4/16.
//  Copyright © 2016 admin. All rights reserved.
//

#import "YLGroupSettingCell.h"
#import <UIKit/UIKit.h>

@interface YLGroupSettingCell()

@property (weak, nonatomic) IBOutlet UIImageView *groupAvatar;
@property (weak, nonatomic) IBOutlet UILabel *groupName;
@property (weak, nonatomic) IBOutlet UIButton *changeGroupName;

@end

@implementation YLGroupSettingCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    // Initialization code
    _changeGroupName.layer.masksToBounds = YES;
    _changeGroupName.layer.cornerRadius = 15;
    _changeGroupName.layer.borderWidth = 1;
    _changeGroupName.layer.borderColor = [[UIColor colorWithRed:240.0/255 green:98.0/255 blue:146.0/255 alpha:1] CGColor];
}

- (void)bindDataWithProtocol:(id<YLGroupChatProtocol>) protocol {
    _groupName.text = protocol._groupTitle;

    [protocol getYLGroupImageWithCompletionBlock:^(NSString *identifier, UIImage * image) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.groupAvatar.image = image;
        });
    }];
}

@end
