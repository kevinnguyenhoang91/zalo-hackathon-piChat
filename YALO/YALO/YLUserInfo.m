//
//  YLUserInfo.m
//  YALO
//
//  Created by BaoNQ on 7/28/16.
//  Copyright © 2016 admin. All rights reserved.
//

#import "YLUserInfo.h"
#import "YLRequestManager.h"
#import "YLExtDefines.h"

NSString * const YLPersonInfoGroupsKey = @"groupList";
NSString * const YLPersonInfoFriendsKey = @"friendList";

@interface YLUserInfo ()

@property (nonatomic) BOOL isRemovedDatabase;
@property (nonatomic) BOOL isObservedGroupList;


@end

@implementation YLUserInfo

+ (instancetype)sharedUserInfo {
    static YLUserInfo *sharedUser = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        sharedUser = [[self alloc] init];
    });
    return sharedUser;
}

- (id)init {
    self = [super init];
    
    if (!self)
        return nil;
    
    self.groupList = [[NSMutableArray alloc] init];
    self.friendList = [[NSMutableArray alloc] init];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userLoggedIn:) name:kNotificationUserLoggedIn object:nil];
    // Lang nghe notification "Da load data tu local"
    
    return self;
}

- (void)userLoggedIn:(NSNotification *)notification {
    
    [self updateWithParameters:notification.userInfo];
    
    if (!_isRemovedDatabase) {
        // removedatabase
        // remove all group list in local
        [[YLShareDBManager dbManagerWithPath:kCacheYALODatabasePath] deleteAllObjectsForClass:[YLGroupChat class]];
        _isRemovedDatabase = true;
    }
    
  //  BOOL result = [self saveObject];
    
    // Load friend from server.
    [[YLRequestManager sharedRequestManager] selectDataFromPath:@"users" completionBlock:^(NSDictionary *data) {
        
        // Remove old friends
        [self.friendList removeAllObjects];
        
        // Load user to array
        for(NSString* key in data.allKeys) {
            NSDictionary* userData = [data objectForKey:key];
            YLFriendInfo* user = [[YLFriendInfo alloc] initWithParameters:userData];
            [self.friendList addObject:user];
        }
        // Luu danh sach ban be xuong DB
        [[YLShareDBManager dbManagerWithPath:kCacheYALODatabasePath] saveObjects:self.friendList];
    }];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationUserModelUpdated object:nil];
}

- (void)loadUserInfoLocal {
    YLDatabaseManager *dbManager = [YLShareDBManager dbManagerWithPath:kCacheYALODatabasePath];
    NSArray *userArray = [dbManager fetchAllObjectForClass:[YLPersonInfo class]];
    NSArray *groupArray = [dbManager fetchAllObjectForClass:[YLPersonInfo class]];
    NSArray *messageArray = [dbManager fetchAllObjectForClass:[YLPersonInfo class]];
    NSArray *groupMemberArray = [dbManager fetchAllObjectForClass:[YLPersonInfo class]];
    
    NSLog(@"%@",userArray);
}

- (id)initWithParameters:(NSDictionary *)params {
    self = [super initWithParameters:params];
    if (!self)
        return nil;
    
    self.groupList = [params objectForKey:YLPersonInfoGroupsKey];
    self.friendList = [params objectForKey:YLPersonInfoFriendsKey];
    return self;
}

- (void)updateWithParameters:(NSDictionary *)params {
    [super updateWithParameters:params];
    
    [self.groupList removeAllObjects];
    
    
    NSDictionary* groupDictionary = [params objectForKey:YLPersonInfoGroupsKey];
    
    // Initialize group list of current user
    if (groupDictionary) {
        for (NSString* idGroup in groupDictionary.allKeys) {
            YLGroupChat* groupChat = [[YLGroupChat alloc] initWithID:idGroup];
            
            NSNumber* state = [groupDictionary objectForKey:idGroup];
            
            if (state && ![state isKindOfClass:[NSString class]]) {
                groupChat.lastSeenMessageTime = [state doubleValue];
            }
            else {
                groupChat.lastSeenMessageTime = 0;
            }
            
            [self.groupList addObject:groupChat];
        }
    }
    
    // When update list complete observe newmessage
    if (!_isObservedGroupList) {
        _isObservedGroupList = true;
        [self observeNewGroupAddedFromServer];
    }

    
    NSMutableArray *newFriendList = [params objectForKey:YLPersonInfoFriendsKey];
    
    // If new data is not equal to 'nil' or new data is NSNull then assign to new data
    if (newFriendList || newFriendList == (id)kCFNull) self.friendList = newFriendList;
}

- (NSDictionary *)exportToDictionary {
//    NSDictionary *dictionary = [super exportToDictionary];
//    
//    return dictionary;
    return nil;
}

- (YLGroupChat *)creatNewGroupWithMembers:(NSArray<YLFriendInfo *> *)members {
    if (!members || members.count < 1)
        return nil;
    
    NSMutableArray *memberIDs = [[NSMutableArray alloc] init];
    NSMutableArray *memberNames = [[NSMutableArray alloc] init];
    
    if (!memberIDs || !memberNames)
        return nil;
    
    for (int i = 0; i < members.count; ++i) {
        if (members[i].userID && members[i].userName) {
            if (![members[i].userID isEqualToString:self.userID]) {
                [memberIDs addObject:members[i].userID];
                [memberNames addObject:members[i].userName];
            }
        }
    }
    BOOL currentUserAdded = NO;
    if (memberIDs.count == 0) {
        [memberIDs addObject:self.userID];
        [memberNames addObject:self.userName];
        
        currentUserAdded = YES;
    }
    
    // Check if the group for this user existed
    if (memberIDs.count == 1 && [YLUserInfo sharedUserInfo].groupList) {
        
        BOOL maybeChatYourself = [memberIDs[0] isEqualToString:self.userID];
        
        for (YLGroupChat *group in [YLUserInfo sharedUserInfo].groupList) {
            if (group && [group._groupMembers objectForKey:memberIDs[0]] != nil) {
                if (!maybeChatYourself) {
                    if (group._groupMembers.allKeys.count == 2) {
                        return group;
                    }
                }
                else {
                    if (group._groupMembers.allKeys.count == 1) {
                        return group;
                    }
                }
            }
        }
    }
    
    if (!currentUserAdded) {
        [memberIDs addObject:self.userID];
        [memberNames addObject:self.userName];
    }

    /* STEP 1: ADD NEW GROUP DATA TO GROUPS BRANCH */
    // Generate dictionary Data from member list.
    NSMutableDictionary *membersDictionary = [[NSMutableDictionary alloc] init];
    for (int i = 0; i < memberIDs.count; ++i) {
        if (memberIDs[i] && memberNames[i])
            [membersDictionary setObject:memberNames[i] forKey:memberIDs[i]];
    }
    
    NSMutableDictionary *dictionaryData = [[NSMutableDictionary alloc] init];
    [dictionaryData setObject:membersDictionary forKey:YLGroupChatMemberIDsKey];
    
    // Insert new group to Firebase tree.
    NSString *newGroupID = [[YLRequestManager sharedRequestManager] insertChildByAutoIDwithData:dictionaryData toPath:kGroupsKey];
    
    
    /* STEP 2: ADD NEW GROUP ID FOR EACH MEMBER */
    for (NSString *memberID in memberIDs) {
        if (memberID) {
            NSString *path = [NSString stringWithFormat:@"%@/%@/%@", kUsersKey, memberID, YLPersonInfoGroupsKey];
            [[YLRequestManager sharedRequestManager] insertChild:newGroupID withData:[NSNumber numberWithDouble:0.0] toPath:path];
        }
    }
    
    [membersDictionary removeAllObjects];
    
    /* STEP 3: GENERATE NEW GROUP MODEL */
    for (int i = 0; i < memberIDs.count; ++i) {
        NSDictionary *groupData = [[NSDictionary alloc] initWithObjectsAndKeys:
                                   newGroupID , YLGroupMemberGroupID,
                                   memberIDs[i] , YLGroupMemberUserID,
                                   memberNames[i], YLGroupMemberNickName,
                                   nil];
        YLGroupMember *groupMemberInfo = [[YLGroupMember alloc] initWithParameters:groupData];
        [membersDictionary setObject:groupMemberInfo forKey:memberIDs[i]];
    }
    
    NSDictionary *groupData = [[NSDictionary alloc] initWithObjectsAndKeys:
                               newGroupID, YLGroupChatIDKey, // Raise an exeption if newGroup is 'nil'
                               @"", YLGroupChatNameKey,
                               membersDictionary, YLGroupChatMemberIDsKey,
                               [[NSMutableArray alloc] init], YLGroupChatMessagesKey,
                               nil];
    
    // Add new group to group list
    YLGroupChat *newGroup = [[YLGroupChat alloc] initWithParameters:groupData];

    
    newGroup.lastSeenMessageTime = 0;
    
    if (!self.groupList) {
        self.groupList = [[NSMutableArray alloc] init];
    }
    if(newGroup) [self.groupList insertObject:newGroup atIndex:0];
    
    // Post a new group observed notification
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationNewGroupObserved object:nil];
    
    return newGroup;
}

- (void)observeNewGroupAddedFromServer {
    
    NSString* pathUserGroupList = [NSString stringWithFormat:@"%@/%@/%@", kUsersKey, self.userID, YLPersonInfoGroupsKey];
    
    [[YLRequestManager sharedRequestManager] observeDataFromPath:pathUserGroupList withEventType:YLDataEventTypeChildAdded completionBlock:^(NSDictionary *data) {
        if (data && data.allKeys.firstObject) {
            
            BOOL groupExisted = NO;
            
            for(YLGroupChat* groupChat in self.groupList) {
                if([groupChat.groupID isEqualToString:data.allKeys.firstObject]) {
                    groupExisted = YES;
                    break;
                }
            }
            
            if (!groupExisted) {
                YLGroupChat* newGroupChat = [[YLGroupChat alloc] initWithID:data.allKeys.firstObject];
                
                if (!self.groupList)
                    self.groupList = [[NSMutableArray alloc] init];
                
                if (newGroupChat) [self.groupList insertObject:newGroupChat atIndex:0];
                
                // Insert vo DB
               // [[YLShareDBManager dbManagerWithPath:kCacheYALODatabasePath] saveObjects:@[newGroupChat]];
            }
            
            // Post a new group observed notification
            [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationNewGroupObserved object:nil];
        }
    }];
}

@end
