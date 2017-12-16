//
//  YLChatCollectionViewCell.m
//  YALO
//
//  Created by qhcthanh on 8/1/16.
//  Copyright © 2016 admin. All rights reserved.
//

#import "YLChatCollectionViewCell.h"
#import "UIImageView+YLNetworking.h"
#import "YLPerson.h"

@interface YLChatCollectionViewCell ()

@end

@implementation YLChatCollectionViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    // Set default font
    self.chatNameLabel.font = kMessageFontInChatMessageCell;
    self.chatTimeLabel.font = kTimeFontInChatMessageCell;
    self.chatNameLabel.font = kNameUserFontInChatMessageCell;
    
    self.chatImageView.clipsToBounds = true;
}

-(void)bindingUIWithProtocol:(id<YLMessageProtocol>)protocol {
    
    self.chatTimeLabel.text = protocol._messageTime;
    self.chatMessageLabel.text = protocol._message;
    
    // Get user avatar with avatarURL
    [self.chatUserImage setImageWithURL:protocol._avatarUserURL placeholderImage:kUserPlaceholderImage identifier:protocol._userID];
    
    // Check protocol and selector
    if ([protocol respondsToSelector:@selector(getAttachmentWithCompletion:)]) {
        // Get attachment
        [protocol getAttachmentWithCompletion:^(NSString *identifier, id attachment) {
            if ( [attachment isKindOfClass:[UIImage class]]) {
                UIImage* image = attachment;
                
                // Check image and messageID
                if (image && [protocol._messageID isEqualToString:identifier]) {
                    self.chatImageView.image = image;
                }
            }
        }];
    }
}

- (void)prepareForReuse {
    [super prepareForReuse];
    
    // Clean UI
    self.chatNameLabel.text = @"";
    self.chatMessageLabel.text = @"";
    self.chatTimeLabel.text = @"";
    self.chatImageView.image = nil;
    self.chatUserImage.image = kUserPlaceholderImage;
}

@end
