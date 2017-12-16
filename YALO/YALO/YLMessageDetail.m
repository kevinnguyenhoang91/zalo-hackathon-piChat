	//
//  YLMessageDetail.m
//  YALO
//
//  Created by BaoNQ on 7/28/16.
//  Copyright © 2016 admin. All rights reserved.
//

#import "YLMessageDetail.h"
#import "NSDate+Format.h"
#import "YLNetworking.h"
#import "YLPerson.h"
#import "YLRequestManager.h"
#import "YLExtDefines.h"


NSString * const YLMessageDetailIDKey = @"messageID";
NSString * const YLMessageDetailUserIDKey = @"userID";
NSString * const YLMessageDetailGroupIDKey = @"groupID";
NSString * const YLMessageDetailTimeKey = @"time";
NSString * const YLMessageDetailContentKey = @"content";
NSString * const YLMessageDetailAttachmentKey = @"attachment";

@interface YLMessageDetail ()  <YLMessageProtocol>

@end

@implementation YLMessageDetail

- (id)initWithParameters:(NSDictionary *)params {
    self = [super init];
    if (!self)
        return nil;
    
    // Get group information from dictionary.
    self.messageID = [params objectForKey:YLMessageDetailIDKey];
    self.userID = [params objectForKey:YLMessageDetailUserIDKey];
    self.groupID = [params objectForKey:YLMessageDetailGroupIDKey];
    
    // Get time
    NSNumber *time = [params objectForKey:YLMessageDetailTimeKey];
    if (time) self.time = [time doubleValue];
    
    self.content = [params objectForKey:YLMessageDetailContentKey];
    self.attachment = [params objectForKey:YLMessageDetailAttachmentKey];
    
    return self;
}

#pragma mark - YLMessageProtocol

- (NSString *)_messageID {
    return self.messageID;
}

- (NSString *)_message {
    return self.content;
}

- (NSString *)_messageTime {
    return [NSDate convertToStringWithTimeIntervalSince1970:self.time];
}

- (NSString *)_userName {
    NSString *userName;
    for (YLFriendInfo *friend in [YLUserInfo sharedUserInfo].friendList) {
        if (friend) {
            if ([friend.userID isEqualToString:self.userID])
            {
                userName = friend.userName;
                break;
            }
        }
    }
    return userName;
}

- (NSString *)_userID {
    
    NSString *userID;
    for (YLFriendInfo *friend in [YLUserInfo sharedUserInfo].friendList) {
        if (friend) {
            if ([friend.userID isEqualToString:self.userID])
            {
                userID = friend.userID;
                break;
            }
        }
    }
    return userID;
}


- (NSURL *)_avatarUserURL {
    
    NSString *avatarUserURL;
    
    for (YLFriendInfo *friend in [YLUserInfo sharedUserInfo].friendList) {
        if (friend) {
            if ([friend.userID isEqualToString:self.userID])
                avatarUserURL = friend.avatarURL;
        }
    }
    
    return [NSURL URLWithString:avatarUserURL];
}

- (void)getImageWithCompletion:(void(^)(NSString* identifier, UIImage* image))completion {
    
    // Check in cache has user avatar with userID
    UIImage* avatar = [[FBCacheManager sharedCache] imageForKey:self.userID];
    
    // If avatar has existed in cache call completionBlock and return block
    if (avatar) {
        completion(self.userID, avatar);
        return;
    }
    
    NSString *avatarURL;
    
    // Find avatarURL in user list with userID
    for (YLFriendInfo *friend in [YLUserInfo sharedUserInfo].friendList) {
        if (friend) {
            if ([friend.userID isEqualToString:self.userID])
                avatarURL = friend.avatarURL;
        }
    }
    
    // If avatarURL with this userID not existed return this block and callback nil image
    if (!avatarURL || [avatarURL isEqualToString:@""]) {
        if(completion) completion(self.userID, nil);
        return;
    }
    
    // Download avatar this user with avatarURL
    YLImageDownloader* imageDowloader = [[YLImageDownloader alloc] initWithSessionManager:[YLSessionManager sharedDefaultSessionManager]];
    
    [imageDowloader downloadImageWithURL:[NSURL URLWithString:avatarURL] identifier:self.userID completionHandler:^(id imageIdentifier, UIImage *image, NSURLResponse *response, NSError *error) {
        
        // If not error call completion image with identifier has downloaded
        if(!error) {
            if (completion) completion(imageIdentifier, image);
        } else {
            // else callback nil
            if(completion) completion(imageIdentifier, nil);
        }
        
    }];
}

- (void)getAttachmentWithCompletion:(void (^)(NSString *, id))completion {
    
    if(self.attachment && [self.attachment isEqualToString:kAttachmentTypeImage]) {
        
        UIImage *image = [[FBCacheManager sharedCache] imageForKey:self.messageID];
        
        if (image) {
            completion(self.messageID,image);
            return;
        }
        
        // Callback default image attachment
        if (completion) completion(self.messageID,[UIImage imageNamed:@"defaultAttachmentImage"]);
        
        // Attachment Path in server
        NSString* attachmentPath = [NSString stringWithFormat:@"%@/%@",kMessageAttachment, self.messageID];
        
        // Fetch attachment with path in server
        [[YLRequestManager sharedRequestManager] selectDataFromPath:attachmentPath completionBlock:^(NSDictionary *data) {
            if (data) {
                // Data attachment in server is String Base64EncodedString
                // When fetch success, we will covert it to NSData and convert to type of Attachment
                NSString *stringData = (NSString *)data;
                
                // Convert string to UIImage
                if (stringData.length > 0) {
                    // Convert String to NSData
                    NSData *imageData = [[NSData alloc]initWithBase64EncodedString:stringData
                                                                           options:NSDataBase64DecodingIgnoreUnknownCharacters];
                    // Covert NSData to UIImage
                    UIImage *image = [UIImage imageWithData:imageData];
                    
                    if (image) {
                        [[FBCacheManager sharedCache] cacheImage:image forKey:self.messageID];

                        if (completion) completion(self.messageID,image);
                    }
                }
            }
        }];
    }
}

@end
