//
//  YLGroupChat.h
//  YALO
//
//  Created by BaoNQ on 7/28/16.
//  Copyright © 2016 admin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YLMessageDetail.h"
#import "YLNetworking.h"
#import "UIImage+Extension.h"
#import "YLGroupMember.h"

extern NSString * const YLGroupChatIDKey;
extern NSString * const YLGroupChatNameKey;
extern NSString * const YLGroupChatMemberIDsKey;
extern NSString * const YLGroupChatMessagesKey;

typedef NS_ENUM(NSInteger,YLGroupDataState) {
    YLGroupDataStateEmpty,
    YLGroupDataStateDownloading,
    YLGroupDataStateDone,
};

@protocol YLGroupChatProtocol <NSObject>

@optional

@property (nonatomic, strong, readonly) NSString *_groupID;
@property (nonatomic, strong, readonly) NSString *_groupTitle;
@property (nonatomic, strong, readonly) NSString *_groupSubTitle;
@property (nonatomic, strong, readonly) NSString *_groupTime;

/**
 *  Fetch data group in server. When fetch complete will call completionBlock to update UI
 *
 *  @param completion The completionBlock when finish fetch data group in server
 */
- (void)fetchDataWithCompletion:(void(^)(NSString *identifier))completion;

/**
 *  Genarate group image with group memeber avatar. The group image depend on group member count
    The group 2 member: The avatar group is avatar of friend
    the group 3 memeber: The avatar group is 3 avatar user circle
    The group 4 member: The avatar group is 4 avatar user circle
    The group garther than 4: The avatar group is 3 random avatar user circle and 1 circle count (groupMember count - 4) E.g: Member count = 6 will +2
 *
 *  @param callbackBlock The callbackBlock when genarate group image finish and return image group, identifier group
 */
- (void)getYLGroupImageWithCompletionBlock:(void(^)(NSString *, UIImage *))callbackBlock;

/**
 *  Check group state. If group had not seen, the group should be bold title
 *
 *  @return The bool value determine group should be bold title
 */
- (BOOL)shouldBeBoldTitle;

@end

@interface YLGroupChat : YLBaseModel

@property (nonatomic, strong) NSString *groupID;
@property (nonatomic, strong) NSString *groupName;
@property (nonatomic) NSTimeInterval lastSeenMessageTime;
@property YLGroupDataState dataState;
@property (nonatomic, strong) NSMutableArray<YLMessageDetail *> *_messages;
//@property (nonatomic, strong) NSMutableDictionary *memberIDs;
@property (nonatomic, strong) NSMutableDictionary<NSString *, YLGroupMember *> *_groupMembers;

/**
 *  Init group chat with a identifier. The other properties will be 'nil'.
 *
 *  @param identifier Identifier for new group.
 *
 *  @return A new-initialized group chat.
 */
- (id)initWithID:(NSString *)identifier;

/**
 *  Init a chat group with parameters. The key for each value in dictionary is a constant.
    For example: YLGroupChatIDKey, YLGroupChatNameKey... See YLGroupChat.h for more details.
 *
 *  @param params A dictionary contains data for the group.
 *
 *  @return A new initialized object.
 */
- (id)initWithParameters:(NSDictionary *)params;

/**
 *  Update group information with parameters.
    The key for each value in dictionary is a constant.
        For example: YLGroupChatIDKey, YLGroupChatNameKey... See YLGroupChat.h for more details.
 *
 *  @param params A dictionary containts new data for the group.
 */
- (void)updateWithParameters:(NSDictionary *)params;

/**
 *  Create new message data from message content and attachment.
 *
 *  @param content    Message content
 *  @param attachment Message attachment.
 */
- (void)pushMessageWithContent:(NSString *)content attachment:(NSString *)attachment;

/**
 *  Used to listen for data changes at a particular location. 
    This is the primary way to read data from the Firebase Database. Your block will be triggered for the initial data and again whenever the data changes.
 */
- (void)observeNewMessageFromServer;

/**
 *  Get datetime of the last message in the message list.
 *
 *  @return The time interval from 1970.
 */
- (NSTimeInterval)getLastMessageTime;

/**
 *  Get content of the last message in the message list.
 *
 *  @return The content of last message
 */
- (NSString *)getLastMessageContent;

@end
