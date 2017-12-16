//
//  YLExtDefines.h
//  YALO
//
//  Created by qhcthanh on 8/2/16.
//  Copyright © 2016 admin. All rights reserved.
//

#ifndef YLExtDefines_h
#define YLExtDefines_h

// Firebase path define
#define kRootKey                    @"YALO"
#define kUsersKey                   @"users"
#define kGroupsKey                  @"groups"
#define kGroupMessagesKey           @"groupMessages"
#define kMessageAttachment          @"messageAttachment"
#define kGroupChangedRefKey                     @"GroupChangedRefKey"

// Notification define
#define kNotificationUserLoggedIn               @"kNotificationUserLoggedIn"
#define kNotificationUserModelUpdated           @"kNotificationUserModelUpdated"
#define kNotificationNewMessageObserved         @"kNotificationNewMessageObserved"
#define kNotificationNewGroupObserved           @"kNotificationNewGroupObserved"
#define kNotificationLoadingData    @"kNotificationUserLoadingData"
#define kNotificationLoadedData    @"kNotificationUserLoadedData"

// ATTACHMENT TYPE
#define kAttachmentTypeImage        @"#ATTACHMENT_IMAGE#"

// Database Path
#define kMainBunldeDatabasePath [[NSBundle mainBundle] pathForResource:@"YALO_DB" ofType:@"db"]
#define kCacheYALODatabasePath [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, TRUE).firstObject stringByAppendingString:@"/YALO_DB.db"]

#endif /* YLExtDefines_h */
