//
//  P2PMessagesViewController.m
//  FireChat
//
//  Created by qhcthanh on 7/28/16.
//  Copyright © 2016 VNG Corp. All rights reserved.
//

#import "P2PMessagesViewController.h"
#import "YLGroupTableViewCell.h"
#import "YLGroupChat.h"
#import "YLRequestManager.h"
#import "YLPerson.h"
#import "YLExtDefines.h"
#import "MessageViewController.h"
#import "SessionContainer.h"

#define kDefaultServiceType @"kDefaultServiceType"

@interface P2PMessagesViewController () <UITableViewDelegate, UITableViewDataSource, SessionContainerDelegate, MCBrowserViewControllerDelegate>

// UI properties
@property (strong, nonatomic) UITableView *groupTableView;

// Private properties
@property (weak ,nonatomic) YLUserInfo *currentUser;
@property (strong, nonatomic) NSMutableArray<SessionContainer *> *p2pSessions;

@end

@implementation P2PMessagesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Set current user
    _currentUser = [YLUserInfo sharedUserInfo];
    _p2pSessions = [[NSMutableArray alloc] init];
    
    _groupTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    _groupTableView.delegate = self;
    _groupTableView.dataSource = self;
    
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

#pragma mark - @IBAction

- (IBAction)addGroupAction:(id)sender {
    
}

// Private helper method for the Multipeer Connectivity local peerID, session, and advertiser.  This makes the application discoverable and ready to accept invitations
- (SessionContainer *)createSession
{
    // Create the SessionContainer for managing session related functionality.
    SessionContainer *sessionContainer = [[SessionContainer alloc] initWithDisplayName:_currentUser.userName serviceType:kDefaultServiceType];
    // Set this view controller as the SessionContainer delegate so we can display incoming Transcripts and session state changes in our table view.
    sessionContainer.delegate = self;
    
    return sessionContainer;
}

- (IBAction)search:(id)sender {
    
    SessionContainer *session = [self createSession];
    [_p2pSessions addObject:session];
    
    // Instantiate and present the MCBrowserViewController
    MCBrowserViewController *browserViewController = [[MCBrowserViewController alloc] initWithServiceType:kDefaultServiceType session:session.session];
    
    browserViewController.delegate = self;
    browserViewController.minimumNumberOfPeers = kMCSessionMinimumNumberOfPeers;
    browserViewController.maximumNumberOfPeers = kMCSessionMaximumNumberOfPeers;
    
    [self presentViewController:browserViewController animated:YES completion:nil];
}

#pragma mark - UITableViewDelegate UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _p2pSessions.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    YLGroupTableViewCell* cell = (YLGroupTableViewCell *)[tableView dequeueReusableCellWithIdentifier:NSStringFromClass([YLGroupTableViewCell class])];
    
    // Get group indexPath
//    YLGroupChat *groupChat = [self.currentUser.groupList objectAtIndex:indexPath.row];
//
//    // Binding UI with YLGroupChatProtocol
//    id<YLGroupChatProtocol> groupChatProtocol = (id<YLGroupChatProtocol>)groupChat;
////    [cell bindDataWithProtocol:groupChatProtocol];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
//    YLGroupChat *currentGroupChat = [_currentUser.groupList objectAtIndex:indexPath.row];
//    
//    // Update state last seen
//    [currentGroupChat setLastSeenMessageTime:[[NSDate new] timeIntervalSince1970]];
//    
//    // Reload cell
//    YLGroupTableViewCell *currentCell = [tableView cellForRowAtIndexPath:indexPath];
//    [currentCell bindDataWithProtocol:(id<YLGroupChatProtocol>)currentGroupChat];
//    
//    // Update cell in other selector
//    [self performSelector:@selector(reloadCell:) withObject:indexPath afterDelay:0.2];
//    
//    // Get MessageViewController with class name and set group
//    MessageViewController* messageViewController = [self.storyboard instantiateViewControllerWithIdentifier:NSStringFromClass([MessageViewController class])];
//    messageViewController.groupChat = currentGroupChat;
//    
//    // Push to messageViewController
//    [self.navigationController pushViewController:messageViewController animated:true];
//    
//    // Deselect
//    [tableView deselectRowAtIndexPath:indexPath animated:false];
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
