//
//  ContactViewCell.h
//  ZaloContact
//
//  Created by qhcthanh on 5/18/16.
//  Copyright © 2016 qhcthanh. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YLPerson.h"

@interface YLFriendCell : UITableViewCell

/**
 *  Binding UI with YLPersonProtocol
    This cell use avatarYLFriendCell in protocol. AvatarImageView mask circle with size (38,38) default.
 *
 *  @param protocol The protocol model to binding with UI
 */
-(void) bindingUIWithProtocol:(id<YLPersonProtocol>)protocol;

@end
