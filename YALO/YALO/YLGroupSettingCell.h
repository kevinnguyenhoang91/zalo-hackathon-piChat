//
//  YLGroupSettingCell.h
//  YALO
//
//  Created by BaoNQ on 8/4/16.
//  Copyright © 2016 admin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YLGroupChat.h"

@interface YLGroupSettingCell : UITableViewCell

/**
 *  Binding UI with YLGroupChatProtocol.
 *
 *  @param protocol The protocol model to bind data.
 */
- (void)bindDataWithProtocol:(id<YLGroupChatProtocol>) protocol;


@end
