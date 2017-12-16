//
//  YLGroupChat.m
//  YALO
//
//  Created by BaoNQ on 7/28/16.
//  Copyright © 2016 admin. All rights reserved.
//

#import "YLGroupChat.h"
#import "YLExtDefines.h"
#import "YLRequestManager.h"
#import "YLPerson.h"
#import "NSDate+Format.h"

NSString * const YLGroupChatIDKey = @"groupID";
NSString * const YLGroupChatNameKey = @"groupName";
NSString * const YLGroupChatMemberIDsKey = @"memberIDs";
NSString * const YLGroupChatMessagesKey = @"messages";

@interface YLGroupChat () <YLGroupChatProtocol> {
    
FIRDatabaseHandle _observerHandle;
FIRDatabaseReference* _groupRef;
dispatch_queue_t _internalSerialQueue;
    
}

@end

@implementation YLGroupChat

- (id)initWithID:(NSString *)identifier {
    self = [super init];
    
    if (!self)
        return nil;
    
    self.groupID = identifier;
    _internalSerialQueue = dispatch_queue_create("com.fresher2016.YALO.YLGroupChat", DISPATCH_QUEUE_SERIAL);
    
    //self.memberIDs = [[NSMutableDictionary alloc] init];
    self._groupMembers = [[NSMutableDictionary alloc] init];
    self._messages = [[NSMutableArray alloc] init];
    _lastSeenMessageTime = 0;

    NSString *childName = [NSString stringWithFormat:@"%@/%@", kRootKey, kGroupMessagesKey];
    _groupRef = [[[[FIRDatabase database] reference] child:childName] child:self.groupID];
    
    [_groupRef removeObserverWithHandle:_observerHandle];
    [self observeNewMessageFromServer];
    
    self.groupName = [self _groupTitle];
    
    return self;
}

- (id)initWithParameters:(NSDictionary *)params {
    self = [super init];
    if (!self)
        return nil;
    
    _internalSerialQueue = dispatch_queue_create("com.fresher2016.YALO.YLGroupChat", DISPATCH_QUEUE_SERIAL);
    
    // Get group information from dictionary.
    self.groupID = [params objectForKey:YLGroupChatIDKey];
    self.groupName = [params objectForKey:YLGroupChatNameKey];
    self._groupMembers = [params objectForKey:YLGroupChatMemberIDsKey];
    self._messages = [params objectForKey:YLGroupChatMessagesKey];
    
    if (!self._groupMembers) self._groupMembers = [[NSMutableDictionary alloc] init];
    if (!self._messages) self._messages = [[NSMutableArray alloc] init];
    
    //[self createGroupMemberWithGroupMemberIDs];
    
    NSString *childName = [NSString stringWithFormat:@"%@/%@", kRootKey, kGroupMessagesKey];
    _groupRef = [[[[FIRDatabase database] reference] child:childName] child:self.groupID];
    
    self.groupName = [self _groupTitle];
    
    [_groupRef removeObserverWithHandle:_observerHandle];
    [self observeNewMessageFromServer];
    
    return self;
}

- (void)updateWithParameters:(NSDictionary *)params {
    
    NSString *newGroupID = [params objectForKey:YLGroupChatIDKey];
    NSString *newGroupName = [params objectForKey:YLGroupChatNameKey];
    NSMutableDictionary *newMemberIDs = [params objectForKey:YLGroupChatMemberIDsKey];
    NSMutableArray *newMessages = [params objectForKey:YLGroupChatMessagesKey];
    
    // If new data is not equal to 'nil' or new data is NSNull then assign to new data
    if (newGroupID || newGroupID == (id)kCFNull) self.groupID = newGroupID;
    if (newGroupName || newGroupName == (id)kCFNull) self.groupName = newGroupName;
    if (newMemberIDs || newMemberIDs == (id)kCFNull) self._groupMembers = newMemberIDs;
    if (newMessages || newMessages == (id)kCFNull) self._messages = newMessages;
    
    //[self createGroupMemberWithGroupMemberIDs];
    
    self.groupName = [self _groupTitle];
}

-(void)dealloc {
    [_groupRef removeObserverWithHandle:_observerHandle];
}

#pragma mark - Public method's

- (void)pushMessageWithContent:(NSString *)content attachment:(NSString *)attachment{
    
    if (!content || (content.length < 1 && (!attachment && ![attachment isEqualToString:@""])))
        return;
    
    // Generate message data
    NSMutableDictionary *messageData = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                                        [YLUserInfo sharedUserInfo].userID, YLMessageDetailUserIDKey,
                                        self.groupID, YLMessageDetailGroupIDKey,
                                        [NSNumber numberWithDouble:[NSDate new].timeIntervalSince1970], YLMessageDetailTimeKey,
                                        content ? content : @"", YLMessageDetailContentKey,
                                        attachment ? kAttachmentTypeImage : @"", YLMessageDetailAttachmentKey,
                                        nil];
    
    NSString* newMessageIDPath = [NSString stringWithFormat:@"%@/%@",kGroupMessagesKey, self.groupID];
    NSString *newAutoMessageID = [[YLRequestManager sharedRequestManager] getAutoIDWithPath:newMessageIDPath];
    NSString *path = [NSString stringWithFormat:@"%@/%@", kGroupMessagesKey, self.groupID];
    
    [messageData setObject:newAutoMessageID forKey:YLMessageDetailIDKey];
    
    if (attachment && ![attachment isEqualToString:@""]) {
        // Push attachment to server
        [[YLRequestManager sharedRequestManager] insertChild:newAutoMessageID withData:attachment toPath:kMessageAttachment withCompletion:^(NSError *error) {
            if(!error) {
                // After the attachment is pushed successfully, add this message to server.
                [[YLRequestManager sharedRequestManager] insertChild:newAutoMessageID withData:messageData toPath:path];
            }
        }];
    } else {
        [[YLRequestManager sharedRequestManager] insertChild:newAutoMessageID withData:messageData toPath:path];
    }

    return;
}

//- (void)createGroupMemberWithGroupMemberIDs {
//    if (!self.groupMembers) {
//        self.groupMembers = [[NSMutableDictionary alloc] init];
//    }
//    
//    [self.groupMembers removeAllObjects];
//    
//    for(NSString *memberID in self.memberIDs) {
//        YLGroupMember *groupMember = [[YLGroupMember alloc] initWithGroupID:self.groupID
//                                                                     userID:memberID
//                                                                   nickName:[self.memberIDs valueForKey:memberID]];
//        [self.groupMembers addObject:groupMember];
//    }
//}

#pragma mark - Getter - Setter

- (void)setLastSeenMessageTime:(NSTimeInterval)lastSeenMessageTime {
    
    NSString* pathGroupIDInUser = [NSString stringWithFormat:@"%@/%@/%@/%@", kUsersKey, [YLUserInfo sharedUserInfo].userID, YLPersonInfoGroupsKey, self.groupID];
    
    [[YLRequestManager sharedRequestManager] setValueAtPath:pathGroupIDInUser
                                                   withData:[NSNumber numberWithDouble:lastSeenMessageTime]];
    _lastSeenMessageTime = lastSeenMessageTime;
}

- (NSTimeInterval)getLastSeenMessageTime {
    return _lastSeenMessageTime;
}

- (NSTimeInterval)getLastMessageTime {
    
    YLMessageDetail* lastMessage = self._messages.lastObject;
    if (lastMessage) {
        return lastMessage.time;
    }
    
    return [[NSDate new] timeIntervalSince1970];
}

- (NSString *)getLastMessageContent {
    
    YLMessageDetail* lastMessage = self._messages.lastObject;
    NSString* nickname = [self._groupMembers objectForKey:lastMessage.userID].nickName;
    
    if (lastMessage) {
        if ([lastMessage.attachment isEqualToString:kAttachmentTypeImage]) {
            return [NSString stringWithFormat:@"%@ %@",nickname, NSLocalizedString(@"sent attachment", @"Group")];
        }
        
        return [NSString stringWithFormat:@"%@: %@",nickname,lastMessage.content];
    }
    
    return NSLocalizedString(@"No message", @"Group");
}

#pragma mark - Observe Message

- (void)observeNewMessageFromServer {
    
    // Add new message observer
    _observerHandle = [_groupRef observeEventType:FIRDataEventTypeChildAdded withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        
        // Create new message Model
        NSMutableDictionary* newMessageData = snapshot.value;
        newMessageData[YLMessageDetailIDKey] = snapshot.key;
        
        YLMessageDetail* newMessage = [[YLMessageDetail alloc] initWithParameters:newMessageData];
        // Add to message array
        [self._messages addObject:newMessage];
        
        // Dua tin nhan moi xuong DB
        
        // Post notification to viewcontroller
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationNewMessageObserved object:nil userInfo:@{ kGroupChangedRefKey : self }];
    }];
}

#pragma mark - YLGroupChatProtocol

- (NSString *)_groupID {
    return self.groupID;
}

- (NSString *)_groupTitle {
    
    if (self.groupName && ![self.groupName isEqualToString:@""]) {
        return self.groupName;
    }
    
    NSString* nameGroup = @"";
    NSArray<YLGroupMember *> *memberNames = self._groupMembers.allValues;

    if (self._groupMembers.count == 2) {
        
        if ([memberNames.firstObject.nickName isEqualToString:[YLUserInfo sharedUserInfo].userName]) {
            nameGroup = [memberNames objectAtIndex:1].nickName;
        }
        else {
            nameGroup = memberNames.firstObject.nickName;
        }
    }
    else {
        for(YLGroupMember* groupMember in memberNames) {
            if ([nameGroup isEqualToString:@""]) {
                nameGroup = groupMember.nickName;
            }
            else if (![groupMember.nickName isEqualToString:@""]) {
                nameGroup = [NSString stringWithFormat:@"%@, %@", nameGroup, groupMember.nickName];
            }
        }
    }
    return nameGroup;
}

- (NSString *)_groupSubTitle {
    return [self getLastMessageContent];
}

- (NSString *)_groupTime {
    return [NSDate convertToStringWithTimeIntervalSince1970:[self getLastMessageTime]];
}

- (BOOL)shouldBeBoldTitle {
    return [self getLastMessageTime] > self.lastSeenMessageTime ? YES : NO;
}

- (void)getYLGroupImageWithCompletionBlock:(void(^)(NSString *, UIImage *))callbackBlock {

    UIImage *image = [[FBCacheManager sharedCache] imageForKey:self.groupID];
    
    if (image) {
        callbackBlock(self.groupID, image);
    } else {
        
        NSInteger numberOfMemmber = [self._groupMembers.allKeys count];
        NSArray *memmberIDArray;
        
        if (numberOfMemmber == 1) {
            // Image is user image
            
            [self getImageOfMemmber:[YLUserInfo sharedUserInfo].userID withCompletionBlock:^(UIImage *image1) {
                callbackBlock(self.groupID, [UIImage clipToCircleImage:image1 withMask:[UIImage imageNamed:@"mask4"]]);
            }];
            
        }
        else if (numberOfMemmber == 2) {
            // Image group is image of memmber;
            
            memmberIDArray = [self getMemberIDsWithNumber:1];
            [self getImageOfMemmber:[memmberIDArray objectAtIndex:0] withCompletionBlock:^(UIImage *image1) {
                callbackBlock(self.groupID, [UIImage clipToCircleImage:image1 withMask:[UIImage imageNamed:@"mask4"]]);
            }];
        }
        else if (numberOfMemmber == 3) {
            // Create image group from three image (2 from friend, 1 from user)
            
            memmberIDArray = [self getMemberIDsWithNumber:2];
            [self getImageOfMemmber:[YLUserInfo sharedUserInfo].userID withCompletionBlock:^(UIImage *image1) {
                [self getImageOfMemmber:[memmberIDArray objectAtIndex:0] withCompletionBlock:^(UIImage *image2) {
                    [self getImageOfMemmber:[memmberIDArray objectAtIndex:1] withCompletionBlock:^(UIImage *image3) {
                        callbackBlock(self.groupID, [UIImage createImageFromThreeImageWithFirstImage:image1 secondImage:image2 thirdImage:image3 withSize:CGSizeMake(60, 60)]);
                    }];
                }];
            }];
        }
        else if (numberOfMemmber == 4) {
            // Create image group from four image (3 from friend, 1 from user)
            
            memmberIDArray = [self getMemberIDsWithNumber:3];
            [self getImageOfMemmber:[YLUserInfo sharedUserInfo].userID withCompletionBlock:^(UIImage *image1) {
                [self getImageOfMemmber:[memmberIDArray objectAtIndex:0] withCompletionBlock:^(UIImage *image2) {
                    [self getImageOfMemmber:[memmberIDArray objectAtIndex:1] withCompletionBlock:^(UIImage *image3) {
                        [self getImageOfMemmber:[memmberIDArray objectAtIndex:2] withCompletionBlock:^(UIImage *image4) {
                            callbackBlock(self.groupID, [UIImage createImageFromFourImageWithFirstImage:image1 secondImage:image2 thirdImage:image3 fourthImage:image4 withSize:CGSizeMake(60, 60)]);
                        }];
                    }];
                }];
            }];
        }
        else {
            // Create image group from four image (2 from any friend, 1 from user, 1 from image create by number of left member in group
            memmberIDArray = [self getMemberIDsWithNumber:2];
            [self getImageOfMemmber:[YLUserInfo sharedUserInfo].userID withCompletionBlock:^(UIImage *image1) {
                // Lau lau crash
                [self getImageOfMemmber:[memmberIDArray objectAtIndex:0] withCompletionBlock:^(UIImage *image2) {
                    [self getImageOfMemmber:[memmberIDArray objectAtIndex:1] withCompletionBlock:^(UIImage *image3) {
                        callbackBlock(self.groupID, [UIImage createImageFromFourImageWithFirstImage:image1 secondImage:image2 thirdImage:image3 fourthImage:[UIImage createImageFromLetters:[NSString stringWithFormat:@"%li", numberOfMemmber - 3]] withSize:CGSizeMake(60, 60)]);
                    }];
                }];
            }];
        }
    }
}

- (NSArray<NSString *> *)getMemberIDsWithNumber:(NSInteger)numberOfMemmber {
    
    NSMutableArray *array = [[NSMutableArray alloc]init];
    
    for (NSString *memmberID in self._groupMembers.allKeys) {
        if (![memmberID isEqualToString:[YLUserInfo sharedUserInfo].userID]) {
            [array addObject:memmberID];
            
            if ([array count] == numberOfMemmber)
                break;
        }
    }
    return array;
}

- (void)getImageOfMemmber:(NSString *)memmberID withCompletionBlock:(void(^)(UIImage *))callbackBlock {
    
    dispatch_async(_internalSerialQueue, ^{
        UIImage *image = [[FBCacheManager sharedCache] imageForKey:memmberID];
        if (!image) {
            
            //Get image URL
            for (YLFriendInfo *friend in [YLUserInfo sharedUserInfo].friendList) {
                
                if ([friend.userID isEqualToString:memmberID]) {
                    
                    YLImageDownloader* imageDowloader = [[YLImageDownloader alloc] initWithSessionManager:[YLSessionManager sharedDefaultSessionManager]];
                    
                    [imageDowloader downloadImageWithURL:[NSURL URLWithString:friend.avatarURL] identifier:memmberID completionHandler:^(id imageIdentifier, UIImage *image, NSURLResponse *response, NSError *error) {
                        if(!error) {
                            [[FBCacheManager sharedCache] cacheImage:image forKey:imageIdentifier];
                            if (callbackBlock)
                                callbackBlock(image);
                        }
                        else {
                            if (callbackBlock)
                                callbackBlock(kUserPlaceholderImage);
                        }
                    }];
                }
            }
        } else {
            if (callbackBlock) callbackBlock(image);
        }
    });
}

- (void)fetchDataWithCompletion:(void (^)(NSString *identifier))completion {
    dispatch_async(_internalSerialQueue, ^{
        
        if (self.dataState == YLGroupDataStateDone) {
            if (completion)
                completion(self.groupID);
        }
        else if (self.dataState == YLGroupDataStateEmpty) {
            self.dataState = YLGroupDataStateDownloading;
            
            NSString* path = [NSString stringWithFormat:@"%@/%@", kGroupsKey, self.groupID];
            
            [[YLRequestManager sharedRequestManager] selectDataFromPath:path completionBlock:^(NSDictionary *data) {
                
                NSMutableDictionary *memberDictionary = [data objectForKey:YLGroupChatMemberIDsKey];
                NSArray *memberIDs = [memberDictionary allKeys];
                NSUInteger numberOfMembers = memberIDs.count;
                
                // init group member
                for (int i = 0; i < numberOfMembers; ++i) {
                    NSDictionary *groupData = [[NSDictionary alloc] initWithObjectsAndKeys:
                                               self.groupID , YLGroupMemberGroupID,
                                               memberIDs[i] , YLGroupMemberUserID,
                                               [memberDictionary objectForKey:memberIDs[i]], YLGroupMemberNickName,
                                               nil];
                    YLGroupMember *groupMemberInfo = [[YLGroupMember alloc] initWithParameters:groupData];
                    
                    [memberDictionary setObject:groupMemberInfo forKey:memberIDs[i]];
                }
                NSDictionary *newGroupData = [[NSDictionary alloc] initWithObjectsAndKeys:
                                              memberDictionary , YLGroupChatMemberIDsKey,
                                              nil];
                [self updateWithParameters:newGroupData];
                
                // Insert vo DB
                [[YLShareDBManager dbManagerWithPath:kCacheYALODatabasePath] saveObjects:@[self]];
                [[YLShareDBManager dbManagerWithPath:kCacheYALODatabasePath] saveObjects:self._messages];
                [[YLShareDBManager dbManagerWithPath:kCacheYALODatabasePath] saveObjects:self._groupMembers.allValues];
                
                self.dataState = YLGroupDataStateDone;
                
                if (completion)
                    completion(self.groupID);
            }];
        }
    });
}

@end
