//
//  ContactViewCell.m
//  ZaloContact
//
//  Created by qhcthanh on 5/18/16.
//  Copyright © 2016 qhcthanh. All rights reserved.
//

#import "YLFriendCell.h"
#import "UIImageView+Mask.h"
#import "UIImageView+YLNetworking.h"

@interface YLFriendCell ()

@property (strong, nonatomic) IBOutlet UIImageView *avatarImageView;
@property (strong, nonatomic) IBOutlet UILabel *nameLabel;

@end

@implementation YLFriendCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    // Mask Avatar
    [_avatarImageView maskAvatarCircle: CGRectMake(0, 0, 38, 38)];
    
    // Set select background color
    UIView *bgColorView = [[UIView alloc] init];
    bgColorView.backgroundColor = [UIColor clearColor];
    [self setSelectedBackgroundView:bgColorView];
}

-(void)bindingUIWithProtocol:(id<YLPersonProtocol>)protocol {
    _nameLabel.text = protocol.userName;
    
    // Get user avatar with avatarURL
    NSURL *avatarURL = [NSURL URLWithString:protocol.avatarURL];
    [_avatarImageView setImageWithURL:avatarURL placeholderImage:kUserPlaceholderImage identifier:protocol.userID];
}

- (void)prepareForReuse {
    [super prepareForReuse];
    
    // Set default avatar and clean name
    _avatarImageView.image = [UIImage imageNamed:@"user non avatar"];
    _nameLabel.text = @"";
}

@end
