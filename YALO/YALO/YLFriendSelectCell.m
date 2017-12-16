//
//  ContactSelectViewCell.m
//  ZaloContact
//
//  Created by qhcthanh on 5/19/16.
//  Copyright © 2016 qhcthanh. All rights reserved.
//

#import "YLFriendSelectCell.h"
#import "UIImageView+Mask.h"
#import "UIImageView+YLNetworking.h"

@interface YLFriendSelectCell ()

@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;

@end

@implementation YLFriendSelectCell

-(void)awakeFromNib {
    [super awakeFromNib];
    
    // Mask avatar image view
    [_avatarImageView maskAvatarCircle: CGRectMake(0, 0, 38, 38)];
}

-(void)bindingUIWithProtocol:(id<YLPersonProtocol>)protocol {
    NSURL *avatarURL = [NSURL URLWithString:protocol.avatarURL];
    [_avatarImageView setImageWithURL:avatarURL placeholderImage:kUserPlaceholderImage identifier:protocol.userID];
}

- (void)prepareForReuse {
    [super prepareForReuse];
    
    // Set default image
    _avatarImageView.image = [UIImage imageNamed:@"user non avatar"];
}


@end
