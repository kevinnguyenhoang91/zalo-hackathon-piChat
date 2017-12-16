//
//  YLPersonInfo.m
//  YALO
//
//  Created by BaoNQ on 7/28/16.
//  Copyright © 2016 admin. All rights reserved.
//

#import "YLPersonInfo.h"
#import "YLNetworking.h"
#import "YLExtDefines.h"

NSString * const YLPersonInfoUserIDKey = @"userID";
NSString * const YLPersonInfoUserNameKey = @"userName";
NSString * const YLPersonInfoAvatarURLKey = @"avatarURL";
NSString * const YLPersonInfoEmailKey = @"email";
NSString * const YLPersonInfoLastLogonTimeKey = @"lastLogonTime";

@interface YLPersonInfo () <YLPersonProtocol>

@end

@implementation YLPersonInfo

- (id)initWithParameters:(NSDictionary *)params {
    self = [super init];
    if (!self)
        return nil;
    
    // Get user infor from dictionary
    self.userID = [params objectForKey:YLPersonInfoUserIDKey];
    self.userName = [params objectForKey:YLPersonInfoUserNameKey];
    self.avatarURL = [params objectForKey:YLPersonInfoAvatarURLKey];
    NSNumber *logOnTime = [params objectForKey:YLPersonInfoLastLogonTimeKey];
    if (logOnTime) self.lastLogonTime = [logOnTime doubleValue];
    
    
    return self;
}

- (void)updateWithParameters:(NSDictionary *)params {
    NSString *newUserID = [params objectForKey:YLPersonInfoUserIDKey];
    NSString *newUserName = [params objectForKey:YLPersonInfoUserNameKey];
    NSString *newAvatarURL = [params objectForKey:YLPersonInfoAvatarURLKey];
    NSString *newEmail = [params objectForKey:YLPersonInfoEmailKey];
    
    NSNumber *logOnTime = [params objectForKey:YLPersonInfoLastLogonTimeKey];
    if (logOnTime) self.lastLogonTime = [logOnTime doubleValue];
    
    if (newUserID || newUserID == (id)kCFNull) self.userID = newUserID;
    if (newUserName || newUserName == (id)kCFNull) self.userName = newUserName;
    if (newAvatarURL || newAvatarURL == (id)kCFNull) self.avatarURL = newAvatarURL;
    if (newEmail || newEmail == (id)kCFNull) self.email = newEmail;
}

- (NSDictionary *)exportToDictionary {
    //    NSDictionary *dictionary = [[NSDictionary alloc] initWithObjectsAndKeys:
    //                                self.userID ? self.userID : [NSNull null], YLPersonInfoUserIDKey,
    //                                self.userName ? self.userName : [NSNull null], YLPersonInfoUserNameKey,
    //                                self.avatarURL ? self.avatarURL : [NSNull null], YLPersonInfoAvatarURLKey,
    //                                self.email ? self.email : [NSNull null], YLPersonInfoEmailKey,
    //                                self.lastLogonTime ? self.lastLogonTime : [NSNull null], YLPersonInfoLastLogonTimeKey,
    //                                nil];
    //    return dictionary;
    return nil;
}

#pragma mark - YLFriendCellProtocol


@end
