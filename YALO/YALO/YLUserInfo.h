//
//  YLUserInfo.h
//  YALO
//
//  Created by BaoNQ on 7/28/16.
//  Copyright © 2016 admin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YLGroupChat.h"
#import "YLFriendInfo.h"

extern NSString * const YLPersonInfoGroupsKey;
extern NSString * const YLPersonInfoFriendsKey;

@interface YLUserInfo : YLPersonInfo

/**
 *  List group chat user has joined
 */
@property (nonatomic, strong) NSMutableArray<YLGroupChat *> *groupList;

/**
 *  List all user in server
 */
@property (nonatomic, strong) NSMutableArray<YLFriendInfo *> *friendList;

/**
 *  Singletion method.
 */
+ (instancetype)sharedUserInfo;

/**
 *  Init a logined-user with parameters. The key for each value in dictionary is a constant.
    This class inherits from YLPersonInfo, and it has two more properties 'NSMutableArray<YLGroupChat *> *groupList' and 'NSMutableArray<YLFriendInfo *> *friendList', so, YLPersonInfoGroupChatKey and YLPersonInfoFriendListKey are its constants.
    
    For example: YLPersonInfoGroupChatKey, YLPersonInfoUserNameKey... See YLPersonInfo.h and YLUserInfo.h for more details.
 *
 *  @param params A dictionary contains data for the user.
 *
 *  @return A new initialized object.
 */
- (id)initWithParameters:(NSDictionary *)params;

/**
 *  Update user information with parameters.
    The key for each value in dictionary is a constant.
    
    For example: YLPersonInfoGroupChatKey, YLPersonInfoUserNameKey... See YLPersonInfo.h and YLUserInfo.h for more details.
 *
 *  @param params A dictionary containts new data for the user.
 */
- (void)updateWithParameters:(NSDictionary *)params;

/**
 *  Export person data to dictionary. Each object in dictionary is identified by a constant key.
    This class inherits from YLPersonInfo, and it has two more properties 'NSMutableArray<YLGroupChat *> *groupList' and 'NSMutableArray<YLFriendInfo *> *friendList', so, YLPersonInfoGroupChatKey and YLPersonInfoFriendListKey are its constants.
    
    For example: YLPersonInfoGroupChatKey, YLPersonInfoUserNameKey... See YLPersonInfo.h and YLUserInfo.h for more details.
 *
 *  @return A new created dictionary contains user data.
 */
- (NSDictionary *)exportToDictionary;

/**
 *  Create new chat group with a given members list.
    The new group will be pushed to server and added to group list automatically.
    If the group for these members already exists, it just return this group.
    The members list may contains the current user or not.
 *
 *  @param members The members list.
 *
 *  @return A new initialized chat group.
 */
- (YLGroupChat *)creatNewGroupWithMembers:(NSArray<YLFriendInfo *> *)members;

- (void)loadUserInfoLocal;

@end






