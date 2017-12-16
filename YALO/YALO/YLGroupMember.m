//
//  YLGroupMember.m
//  YALO
//
//  Created by qhcthanh on 8/9/16.
//  Copyright © 2016 admin. All rights reserved.
//

#import "YLGroupMember.h"
#import "YLExtDefines.h"

NSString * const YLGroupMemberGroupID = @"groupID";
NSString * const YLGroupMemberNickName = @"nickName";
NSString * const YLGroupMemberUserID = @"memberID";

@implementation YLGroupMember

- (id)init {
    self = [super init];
    
    if (self) {
        self.groupID = @"";
        self.userID = @"";
        self.nickName = @"";
    }
    return self;
}
//
//- (id)initWithGroupID:(NSString *)groupID userID:(NSString *)userID nickName:(NSString *)nickName {
//    self = [super init];
//    
//    if (self) {
//        self.groupID = groupID;
//        self.userID = userID;
//        self.nickName = nickName;
//    }
//    
//    return self;
//}

- (id)initWithParameters:(NSDictionary *)params {
    self = [super init];
    if (!self)
        return nil;
    
    self.groupID = [params objectForKey:YLGroupMemberGroupID];
    self.userID = [params objectForKey:YLGroupMemberUserID];
    self.nickName = [params objectForKey:YLGroupMemberNickName];
    
    return self;
}

- (void)updateWithParameters:(NSDictionary *)params {
    NSString *newGroupID = [params objectForKey:YLGroupMemberGroupID];
    NSString *newUserID = [params objectForKey:YLGroupMemberUserID];
    NSString *newNickname = [params objectForKey:YLGroupMemberNickName];
    
    // If new data is not equal to 'nil' or new data is NSNull then assign to new data
    if (newGroupID || newGroupID == (id)kCFNull) self.groupID = newGroupID;
    if (newUserID || newUserID == (id)kCFNull) self.userID = newUserID;
    if (newNickname || newNickname == (id)kCFNull) self.nickName = newNickname;
}

@end
