//
//  GroupChatViewController.m
//  FireChat
//
//  Created by qhcthanh on 7/28/16.
//  Copyright © 2016 VNG Corp. All rights reserved.
//

#import "GroupChatViewController.h"
#import "YLGroupTableViewCell.h"
#import "YLGroupChat.h"
#import "YLRequestManager.h"
#import "YLPerson.h"
#import "YLExtDefines.h"
#import "MessageViewController.h"
#import "P2PMessagesViewController.h"

@interface GroupChatViewController () <UITableViewDelegate, UITableViewDataSource>

// UI properties
@property (weak, nonatomic) IBOutlet UITableView *groupTableView;

// Private properties
@property (weak ,nonatomic) YLUserInfo *currentUser;

@end

@implementation GroupChatViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Set current user
    _currentUser = [YLUserInfo sharedUserInfo];
    
    // Add observe notification
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(observeNewGroupAdded) name:kNotificationNewGroupObserved object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(observeNewMessageAdded:) name:kNotificationNewMessageObserved object:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // Set default properties tableview
    _groupTableView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
    _groupTableView.tableFooterView = [UIView new];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Receive Notification

- (void)observeNewMessageAdded:(NSNotification *)notification {
    if (notification.userInfo) {
        // Get kGroupChangedRefKey object in userInfo
        id groupRef = [notification.userInfo objectForKey:kGroupChangedRefKey];
        
        if (groupRef) {
            // Get index's group in currentUser.groupList if indexOfGroup is NSNotFound will return
            NSInteger indexOfGroup = [_currentUser.groupList indexOfObject:groupRef];
            if (indexOfGroup == NSNotFound)
                return;
            
            // Move to first in groupList array
            [_currentUser.groupList removeObjectAtIndex:indexOfGroup];
            [_currentUser.groupList insertObject:groupRef atIndex:0];
            
            // Update position this group (move to first tableView)
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:indexOfGroup inSection:0];
            [_groupTableView moveRowAtIndexPath:indexPath toIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
            
            // Update state's group. This will check group should be bold title
            id groupCell = [_groupTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
            [groupCell bindDataWithProtocol:(id<YLGroupChatProtocol>)groupRef];
            
        }
    }
}

- (void)observeNewGroupAdded {
    // Get current cell in GroupTableView
    NSInteger currentIndexGroupTableView = [_groupTableView numberOfRowsInSection:0];
    
    // Check if currentIndexGroupTableView less than groupList.count, it need insert
    if (currentIndexGroupTableView < _currentUser.groupList.count) {
        
        // Insert new item to first
        NSIndexPath* newIndexPath = [NSIndexPath indexPathForItem:0 inSection:0];
        [_groupTableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}

#pragma mark - @IBAction

- (IBAction)addGroupAction:(id)sender {
    
}

- (IBAction)signOut:(id)sender {
//    // SignOut Firebase with nil error references
//    [[FIRAuth auth] signOut:nil];
//    
//    // SignOut Google
//    [[GIDSignIn sharedInstance] signOut];
//    
//    // Back to AuthenticationViewController
//    [self dismissViewControllerAnimated:true completion:nil];
    
    
    
    P2PMessagesViewController *p2pVC = [[P2PMessagesViewController alloc] init];
    
    [self.navigationController pushViewController:p2pVC animated:YES];
}

#pragma mark - UITableViewDelegate UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _currentUser.groupList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    YLGroupTableViewCell* cell = (YLGroupTableViewCell *)[tableView dequeueReusableCellWithIdentifier:NSStringFromClass([YLGroupTableViewCell class])];
    
    // Get group indexPath
    YLGroupChat *groupChat = [self.currentUser.groupList objectAtIndex:indexPath.row];

    // Binding UI with YLGroupChatProtocol
    id<YLGroupChatProtocol> groupChatProtocol = (id<YLGroupChatProtocol>)groupChat;
    [cell bindDataWithProtocol:groupChatProtocol];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    YLGroupChat *currentGroupChat = [_currentUser.groupList objectAtIndex:indexPath.row];
    
    // Update state last seen
    [currentGroupChat setLastSeenMessageTime:[[NSDate new] timeIntervalSince1970]];
    
    // Reload cell
    YLGroupTableViewCell *currentCell = [tableView cellForRowAtIndexPath:indexPath];
    [currentCell bindDataWithProtocol:(id<YLGroupChatProtocol>)currentGroupChat];
    
    // Update cell in other selector
    [self performSelector:@selector(reloadCell:) withObject:indexPath afterDelay:0.2];
    
    // Get MessageViewController with class name and set group
    MessageViewController* messageViewController = [self.storyboard instantiateViewControllerWithIdentifier:NSStringFromClass([MessageViewController class])];
    messageViewController.groupChat = currentGroupChat;
    
    // Push to messageViewController
    [self.navigationController pushViewController:messageViewController animated:true];
    
    // Deselect
    [tableView deselectRowAtIndexPath:indexPath animated:false];
}

- (void)reloadCell:(id)object {
    NSIndexPath *indexPath = object;
    
    // If indexPath reloadCell
    if (indexPath) {
        YLGroupTableViewCell *currentCell = [_groupTableView cellForRowAtIndexPath:indexPath];
        
        // Reload cell at indexPath
        YLGroupChat *currentGroupChat = [_currentUser.groupList objectAtIndex:indexPath.row];
        [currentCell bindDataWithProtocol:(id<YLGroupChatProtocol>)currentGroupChat];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 70.0f;
}


@end
