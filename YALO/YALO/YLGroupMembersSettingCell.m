//
//  YLGroupMembersSettingCell.m
//  YALO
//
//  Created by BaoNQ on 8/5/16.
//  Copyright © 2016 admin. All rights reserved.
//

#import "YLGroupMembersSettingCell.h"
#import "YLUserInfoCollectionViewCell.h"

@interface YLGroupMembersSettingCell() <UICollectionViewDelegate, UICollectionViewDataSource>

@property (nonatomic) NSMutableArray<YLPersonInfo *> *membersGroup;
@property (weak, nonatomic) YLGroupChat *groupChat;
@property CGSize itemFriendCellSize;
@end

@implementation YLGroupMembersSettingCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    _membersGroup = [NSMutableArray new];
    _itemFriendCellSize = CGSizeMake(CGRectGetMaxX(self.frame)/3 - 8, 115);
}

- (void)setGroupBindingData:(YLGroupChat *)groupChat {
    _groupChat = groupChat;
    
    for (YLPersonInfo* friendInfo in [YLUserInfo sharedUserInfo].friendList) {
        if ([_groupChat._groupMembers objectForKey:friendInfo.userID]) {
            [_membersGroup addObject:friendInfo];
        }
    }
    
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _membersGroup.count + 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        id addFriendCell = [collectionView dequeueReusableCellWithReuseIdentifier:@"AddFriendCell" forIndexPath:indexPath];
        return addFriendCell;
    }
    // Get friend
    id<YLPersonProtocol> protocol = (id<YLPersonProtocol>)[_membersGroup objectAtIndex:indexPath.row - 1];
    
    YLUserInfoCollectionViewCell *friendCell = [collectionView dequeueReusableCellWithReuseIdentifier:@"FriendCell" forIndexPath:indexPath];
    [friendCell bindDataWithProtocol:protocol];
    
    return friendCell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return _itemFriendCellSize;
}

@end
