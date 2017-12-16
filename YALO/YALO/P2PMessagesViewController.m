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
#import "P2PChatViewController.h"

#define kDefaultServiceType @"servicetype"

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
    [self.view addSubview:_groupTableView];
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

#pragma mark - SessionContainerDelegate

- (void)receivedTranscript:(Transcript *)transcript
{
//    // Add to table view data source and update on main thread
//    dispatch_async(dispatch_get_main_queue(), ^{
//        [self insertTranscript:transcript];
//    });
}

- (void)updateTranscript:(Transcript *)transcript
{
//    // Find the data source index of the progress transcript
//    NSNumber *index = [_imageNameIndex objectForKey:transcript.imageName];
//    NSUInteger idx = [index unsignedLongValue];
//    // Replace the progress transcript with the image transcript
//    [_transcripts replaceObjectAtIndex:idx withObject:transcript];
//    
//    // Reload this particular table view row on the main thread
//    dispatch_async(dispatch_get_main_queue(), ^{
//        NSIndexPath *newIndexPath = [NSIndexPath indexPathForRow:idx inSection:0];
//        [self.tableView reloadRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
//    });
}


#pragma mark - MCBrowserViewControllerDelegate methods

// Override this method to filter out peers based on application specific needs
- (BOOL)browserViewController:(MCBrowserViewController *)browserViewController shouldPresentNearbyPeer:(MCPeerID *)peerID withDiscoveryInfo:(NSDictionary *)info
{
    return YES;
}

// Override this to know when the user has pressed the "done" button in the MCBrowserViewController
- (void)browserViewControllerDidFinish:(MCBrowserViewController *)browserViewController
{
    [browserViewController dismissViewControllerAnimated:YES completion:^{
    
        SessionContainer *session = [_p2pSessions lastObject];
        
        if (session) {
            // Get MessageViewController with class name and set group
            P2PChatViewController* messageViewController = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"P2PChatViewController"];
            session.delegate = messageViewController;
            messageViewController.sessionContainer = session;
            
            // Push to messageViewController
            [self.navigationController pushViewController:messageViewController animated:true];
        }
    }];
    
  
}

// Override this to know when the user has pressed the "cancel" button in the MCBrowserViewController
- (void)browserViewControllerWasCancelled:(MCBrowserViewController *)browserViewController
{
    [browserViewController dismissViewControllerAnimated:YES completion:nil];
    
    if (_p2pSessions.count > 0)
        [_p2pSessions removeLastObject];
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
//    [cell bindDataWithProtocol:groupChatProtocol];
    
    SessionContainer *session = nil;
    
    if (indexPath.row < _p2pSessions.count) {
        session = _p2pSessions[indexPath.row];
    }
    
    cell.nameGroupLabel.text = @"P2P Group chat";
    cell.pictureGroupImageView.image = [UIImage imageNamed:@"user non avatar"];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    SessionContainer *session = nil;
    
    if (indexPath.row < _p2pSessions.count) {
        session = _p2pSessions[indexPath.row];
    }
    
    if (session) {
        // Get MessageViewController with class name and set group
        P2PChatViewController* messageViewController = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"P2PChatViewController"];
        session.delegate = messageViewController;
        messageViewController.sessionContainer = session;
        
        // Push to messageViewController
        [self.navigationController pushViewController:messageViewController animated:true];
    }
    
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
