//
//  GroupSettingViewController.m
//  YALO
//
//  Created by BaoNQ on 8/4/16.
//  Copyright © 2016 admin. All rights reserved.
//

#import "GroupSettingViewController.h"
#import "YLGroupSettingCell.h"
#import "YLGroupMembersSettingCell.h"

typedef NS_ENUM (NSUInteger, GroupSettingCell) {
    kGroupSettingTitleCell = 0,
    kGroupSettingChangeBackgroundCell,
    kGroupSettingRemoveMessageCell,
    kGroupSettingLeaveGroupCell,
    kGroupSettingKickMemberCell,
    kGroupSettingMemberListCell,
};

#define kGroupSettingTitleCellHeight 80
#define kGroupSettingNormalCellHeight 50
#define kNumberOfCells 6

@interface GroupSettingViewController () <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property CGFloat heightMemberCell;

@end

@implementation GroupSettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Calculate cell size in setting
    CGFloat memberItemCellWidth = CGRectGetMaxX(self.view.frame)/3 - 24;
    NSInteger numberOfLineMemberItem = (memberItemCellWidth * self.groupInfo._groupMembers.count + 5) / CGRectGetMaxX(self.view.frame) + 1;
    _heightMemberCell = numberOfLineMemberItem * 130 + 20;
}

#pragma mark - IBAction

- (IBAction)backAction:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - UITableViewDataSource + UITableViewDelegate

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == kGroupSettingTitleCell) {
        YLGroupSettingCell *groupSettingCell = (YLGroupSettingCell *)[tableView dequeueReusableCellWithIdentifier:@"GroupTitleCell"];
        
        [groupSettingCell bindDataWithProtocol:(id<YLGroupChatProtocol>)self.groupInfo];
        
        return groupSettingCell;
    }
    else if (indexPath.row == kGroupSettingChangeBackgroundCell) {
        UITableViewCell *normalCell = [tableView dequeueReusableCellWithIdentifier:@"NormalCell"];
        normalCell.textLabel.font = kGroupSettingTitleFont;
        normalCell.textLabel.text = NSLocalizedString(@"Change background", @"Setting");
        return normalCell;
    }
    else if (indexPath.row == kGroupSettingRemoveMessageCell) {
        UITableViewCell *normalCell = [tableView dequeueReusableCellWithIdentifier:@"NormalCell"];
        normalCell.textLabel.font = kGroupSettingTitleFont;
        normalCell.textLabel.text = NSLocalizedString(@"Remove message", @"Setting");
        return normalCell;
    }
    else if (indexPath.row == kGroupSettingLeaveGroupCell) {
        UITableViewCell *normalCell = [tableView dequeueReusableCellWithIdentifier:@"NormalCell"];
        normalCell.textLabel.font = kGroupSettingTitleFont;
        normalCell.textLabel.text = NSLocalizedString(@"Leave group", @"Setting");
        return normalCell;
    }
    else if (indexPath.row == kGroupSettingKickMemberCell) {
        UITableViewCell *normalCell = [tableView dequeueReusableCellWithIdentifier:@"NormalCell"];
        normalCell.textLabel.font = kGroupSettingTitleFont;
        normalCell.textLabel.text = NSLocalizedString(@"Kick group", @"Setting");
        return normalCell;
    }
    else {
        YLGroupMembersSettingCell *settingCell = [tableView dequeueReusableCellWithIdentifier:@"MembersCell"];
        [settingCell setGroupBindingData:self.groupInfo];
        
        return settingCell;
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return kNumberOfCells;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == kGroupSettingTitleCell) {
        return kGroupSettingTitleCellHeight;
    }
    else if (indexPath.row == kGroupSettingMemberListCell) {
        return _heightMemberCell;
    }
    else {
        return kGroupSettingNormalCellHeight;
    }
}

@end
