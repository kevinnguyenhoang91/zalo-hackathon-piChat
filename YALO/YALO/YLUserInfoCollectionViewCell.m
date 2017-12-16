//
//  YLUserInfoCollectionViewCell.m
//  YALO
//
//  Created by BaoNQ on 8/5/16.
//  Copyright © 2016 admin. All rights reserved.
//

#import "YLUserInfoCollectionViewCell.h"
#import "UIImageView+Mask.h"
#import "UIImageView+YLNetworking.h"

@implementation YLUserInfoCollectionViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    [self.memberPhoto maskAvatarCircle:CGRectMake(0, 0, 60, 60)];
}

- (void)bindDataWithProtocol:(id<YLPersonProtocol>) protocol {
    self.memberName.text = protocol.userName;
    
    // Set user avatar with URL
    [self.memberPhoto setImageWithURL:[NSURL URLWithString:protocol.avatarURL]placeholderImage:kUserPlaceholderImage identifier:protocol.userID];
    
}

@end
