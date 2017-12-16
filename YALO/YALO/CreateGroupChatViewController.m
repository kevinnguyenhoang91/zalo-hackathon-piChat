//
//  CreateGroupChatViewController.m
//  YALO
//
//  Created by qhcthanh on 7/29/16.
//  Copyright © 2016 admin. All rights reserved.
//

#import "CreateGroupChatViewController.h"
#import "YLRequestManager.h"
#import "YLPerson.h"
#import "YLFriendCell.h"
#import "YLFriendSelectCell.h"
#import "MessageViewController.h"

#define kSelectFriendTopHiddenConstraint -50
#define kSelectFriendTopShowConstraint 0

@interface CreateGroupChatViewController() <UICollectionViewDelegate, UICollectionViewDataSource, UITableViewDelegate, UITableViewDataSource>

// UI properties
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *selectFriendTopConstraint;
@property (weak, nonatomic) IBOutlet UICollectionView *selectFriendCollectionView;
@property (weak, nonatomic) IBOutlet UITableView *friendTableView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *createGroupButton;

// Private properties
@property YLUserInfo* currentUser;
@property NSMutableArray *selectFriendArray;

@end

@implementation CreateGroupChatViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Initialize
    _currentUser = [YLUserInfo sharedUserInfo];
    _selectFriendArray = [NSMutableArray new];
    
    // Setup FrienTableView Editable
    [super setEditing:true];
    
    _friendTableView.allowsMultipleSelectionDuringEditing = YES;
    [_friendTableView setEditing:YES];
    _friendTableView.allowsMultipleSelection = YES;
    
}

#pragma mark - IBAction

- (IBAction)createGroupAction:(id)sender {
    
    // Create new group
    YLGroupChat* groupChat = [_currentUser creatNewGroupWithMembers:_selectFriendArray];
    
    // Move to MessageViewController
    MessageViewController* messageVC = [self.storyboard instantiateViewControllerWithIdentifier:NSStringFromClass([MessageViewController class])];
    messageVC.groupChat = groupChat;
    
    [self.navigationController pushViewController:messageVC animated:true];
    
}
- (IBAction)backAction:(id)sender {
    [self.navigationController popViewControllerAnimated:true];
}

#pragma mark - UITableViewDelgate + UITableVieDatasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [YLUserInfo sharedUserInfo].friendList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    YLFriendCell *cell = (YLFriendCell *)[tableView dequeueReusableCellWithIdentifier:NSStringFromClass([YLFriendCell class])];
    
    // Get friendInfo with indexPath.row
    YLFriendInfo *friendInfo = [[YLUserInfo sharedUserInfo].friendList objectAtIndex:indexPath.row];
    
    // Binding Friend Data with Protocol in Cell
    id<YLPersonProtocol> protocol = (id)friendInfo;
    [cell bindingUIWithProtocol:protocol];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Get friend select and add to selectArray
    YLFriendInfo *friend = [[YLUserInfo sharedUserInfo].friendList objectAtIndex:indexPath.row];
    [_selectFriendArray addObject:friend];
    
    // Insert new row collectionview
    NSIndexPath* newIndexPath = [NSIndexPath indexPathForItem:_selectFriendArray.count-1 inSection:0];
    [_selectFriendCollectionView insertItemsAtIndexPaths:@[newIndexPath]];
    
    // If first item show selectCollectionView and enable CreateGroup
    if (_selectFriendArray.count == 1) {
        [self setHiddenFriendSelectCollectionView:false];
        _createGroupButton.enabled = true;
    }
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Get friendInfo with indexPath.row
    YLFriendInfo *friend = [[YLUserInfo sharedUserInfo].friendList objectAtIndex:indexPath.row];
    
    // Get index in _selectFriendArray and delete
    NSInteger inFriendArrayIndex = [_selectFriendArray indexOfObject:friend];
    [_selectFriendArray removeObject:friend];
    
    // Delete item at inFriendArrayIndex
    [_selectFriendCollectionView deleteItemsAtIndexPaths:@[ [NSIndexPath indexPathForItem:inFriendArrayIndex inSection:0] ]];
    
    // If remove last item hide selectCollectionView and disable CreateGroup
    if (_selectFriendArray.count == 0) {
        [self setHiddenFriendSelectCollectionView:true];
        _createGroupButton.enabled = false;
    }

}

- (void)setHiddenFriendSelectCollectionView:(BOOL)isHidden {
    // Default top SelectCollectionView Top Constraint 0 - is show, -50 is Hide
    CGFloat constraint = kSelectFriendTopShowConstraint;
    if (isHidden) {
        constraint = kSelectFriendTopHiddenConstraint;
    }
    
    // Animation to show or hide SelectCollectionView
    _selectFriendTopConstraint.constant = constraint;
    [UIView animateWithDuration:0.3 animations:^{
        [self.view layoutIfNeeded];
    }];
}

#pragma mark - CollectionwDelgate + Datasource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _selectFriendArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    YLFriendSelectCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([YLFriendSelectCell class]) forIndexPath:indexPath];
    
    // Binding Data with protocol
    id<YLPersonProtocol> protocol = [_selectFriendArray objectAtIndex:indexPath.row];
    [cell bindingUIWithProtocol:protocol];
    
    return cell;
}


@end



