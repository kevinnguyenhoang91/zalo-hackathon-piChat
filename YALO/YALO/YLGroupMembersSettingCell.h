//
//  YLGroupMembersSettingCell.h
//  YALO
//
//  Created by BaoNQ on 8/5/16.
//  Copyright © 2016 admin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YLPerson.h"
#import "YLGroupChat.h"

@interface YLGroupMembersSettingCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

/**
 *  Set group chat to binding data. This cell will get members in group
 *
 *  @param groupChat The group chat will get member
 */
- (void)setGroupBindingData:(YLGroupChat *)groupChat;

@end
