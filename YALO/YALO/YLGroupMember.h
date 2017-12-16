//
//  YLGroupMember.h
//  YALO
//
//  Created by qhcthanh on 8/9/16.
//  Copyright © 2016 admin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YLBaseModel.h"

extern NSString * const YLGroupMemberGroupID;
extern NSString * const YLGroupMemberNickName;
extern NSString * const YLGroupMemberUserID;

@interface YLGroupMember : YLBaseModel

@property (nonatomic, strong) NSString *groupID;
@property (nonatomic, strong) NSString *userID;
@property (nonatomic, strong) NSString *nickName;

///**
// *  Initiallize YLGroupMember. The Group member is created by YLGroupInfo with userID, groupID, nickName
// *
// *  @param groupID  The groupID of member
// *  @param userID   The member userID
// *  @param nickName The nickName of user in group
// */
//- (id)initWithGroupID:(NSString *)groupID userID:(NSString *)userID nickName:(NSString *)nickName;

/**
 *  Init a chat group member with parameters. The key for each value in dictionary is a constant.
 For example: YLGroupMemberGroupID, YLGroupMemberNickName... See YLGroupMember.h for more details.
 *
 *  @param params A dictionary contains data for the group member.
 *
 *  @return A new initialized object.
 */
- (id)initWithParameters:(NSDictionary *)params;

/**
 *  Update group information with parameters. The key for each value in dictionary is a constant.
    For example: YLGroupMemberGroupID, YLGroupMemberNickName... See YLGroupMember.h for more details.
 *
 *  @param params A dictionary containts new data for the group member.
 */
- (void)updateWithParameters:(NSDictionary *)params;


@end
