//
//  GroupTableViewCell.h
//  FireChat
//
//  Created by qhcthanh on 7/28/16.
//  Copyright © 2016 VNG Corp. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YLGroupChat.h"



@interface YLGroupTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *nameGroupLabel;
@property (weak, nonatomic) IBOutlet UIImageView *pictureGroupImageView;
@property (weak, nonatomic) IBOutlet UILabel *lastMessageLabel;
@property (weak, nonatomic) IBOutlet UILabel *lastTimeLabel;

/**
 *  Binding UI with YLGroupChatProtocol This cell binding UI use:
        groupTitle to nameGroupLabel text
        groupSubTitle to lastMessageLabel text
        groupTime to lastTimeLabel text
 *
 *  @param protocol The protocol model to binding with UI
 */
- (void)bindDataWithProtocol:(id<YLGroupChatProtocol>) protocol;

- (void)updateState:(id<YLGroupChatProtocol>) protocol;

@end
