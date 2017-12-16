//
//  GroupTableViewCell.m
//  FireChat
//
//  Created by qhcthanh on 7/28/16.
//  Copyright © 2016 VNG Corp. All rights reserved.
//

#import "YLGroupTableViewCell.h"
#import "UIImageView+Mask.h"


@implementation YLGroupTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (void)bindDataWithProtocol:(id<YLGroupChatProtocol>) protocol {
    // Binding UI with Protocol
    // Fetch data of group in server
    [protocol fetchDataWithCompletion:^(NSString *identifier){
        if ([identifier isEqualToString:protocol._groupID]) {
            // Update data in main queue if fetch complete
            dispatch_async(dispatch_get_main_queue(), ^{
                self.nameGroupLabel.text = protocol._groupTitle;
                self.lastMessageLabel.text = protocol._groupSubTitle;
                self.lastTimeLabel.text = protocol._groupTime;
                
                // If shouldBeBoldTitle (new message), this will set contentView with PinkColor(RGB:252,228,236)
                // else this will default WhiteColor
                if ([protocol shouldBeBoldTitle]) {
                    self.contentView.backgroundColor = [UIColor colorWithRed:252.0/255 green:228.0/255 blue:236.0/255 alpha:1];
                } else {
                    self.contentView.backgroundColor = [UIColor whiteColor];
                }
            });
            
            // Get image create by group member
            [protocol getYLGroupImageWithCompletionBlock:^(NSString *identifier, UIImage * image) {
                if ([identifier isEqualToString:protocol._groupID]) {
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        self.pictureGroupImageView.image = image;
                    });
                }
            }];
            
        }
    }];
    
}

- (void)updateState:(id<YLGroupChatProtocol>) protocol {
    // If shouldBeBoldTitle (new message), this will set contentView with PinkColor(RGB:252,228,236)
    // else this will default WhiteColor
    if ([protocol shouldBeBoldTitle]) {
        self.contentView.backgroundColor = [UIColor colorWithRed:252.0/255 green:228.0/255 blue:236.0/255 alpha:1];
    } else {
        self.contentView.backgroundColor = [UIColor whiteColor];
    }
}

- (void)prepareForReuse {
    [super prepareForReuse];
    
    // Clean UI
    self.contentView.backgroundColor = [UIColor whiteColor];
    self.nameGroupLabel.text = @"";
    self.lastMessageLabel.text = @"";
    self.lastTimeLabel.text = @"";
    self.pictureGroupImageView.image = [UIImage imageNamed:@"Groups"];
}

@end
