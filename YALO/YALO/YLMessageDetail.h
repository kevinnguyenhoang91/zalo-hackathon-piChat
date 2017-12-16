//
//  YLMessageDetail.h
//  YALO
//
//  Created by BaoNQ on 7/28/16.
//  Copyright © 2016 admin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YLBaseModel.h"

extern NSString * const YLMessageDetailIDKey;
extern NSString * const YLMessageDetailUserIDKey;
extern NSString * const YLMessageDetailGroupIDKey;
extern NSString * const YLMessageDetailTimeKey ;
extern NSString * const YLMessageDetailContentKey ;
extern NSString * const YLMessageDetailAttachmentKey;

@protocol YLMessageProtocol <NSObject>

@property (nonatomic, strong, readonly) NSString *_userName;
@property (nonatomic, strong, readonly) NSString *_message;
@property (nonatomic, strong, readonly) NSString *_messageTime;
@property (nonatomic, strong, readonly) NSString *_userID;
@property (nonatomic, strong, readonly) NSString *_messageID;
@property (nonatomic, strong, readonly) NSURL *_avatarUserURL;


- (void)getImageWithCompletion:(void(^)(NSString* identifier, UIImage* image))completion;

- (void)getAttachmentWithCompletion:(void(^)(NSString* identifier, id attachment))completion;

@end

@interface YLMessageDetail : YLBaseModel

@property (nonatomic, strong) NSString *messageID;
@property (nonatomic, strong) NSString *userID;
@property (nonatomic, strong) NSString *groupID;
@property (nonatomic) NSTimeInterval time;
@property (nonatomic, strong) NSString *content;
@property (nonatomic, strong) NSString *attachment;

/**
 *  Init a message with parameters. The key for each value in dictionary is a constant.
    For example: YLMessageDetailIDKey, YLMessageDetailUserIDKey... See YLMessageDetail.h for more details.
 *
 *  @param params A dictionary contains data for the message.
 *
 *  @return A new initialized object.
 */
- (id)initWithParameters:(NSDictionary *)params;

@end
