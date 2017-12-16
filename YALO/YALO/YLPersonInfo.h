//
//  YLPersonInfo.h
//  YALO
//
//  Created by BaoNQ on 7/28/16.
//  Copyright © 2016 admin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YLBaseModel.h"

#define kUserPlaceholderImage [UIImage imageNamed:@"user non avatar"]

extern NSString * const YLPersonInfoUserIDKey;
extern NSString * const YLPersonInfoUserNameKey;
extern NSString * const YLPersonInfoAvatarURLKey;
extern NSString * const YLPersonInfoEmailKey;
extern NSString * const YLPersonInfoLastLogonTimeKey;

@protocol YLPersonProtocol <NSObject>

@property (nonatomic, strong, readonly) NSString *userID;
@property (nonatomic, strong, readonly) NSString *userName;
@property (nonatomic, strong, readonly) NSString *avatarURL;

@end

@interface YLPersonInfo : YLBaseModel

@property (nonatomic, strong) NSString *userID;
@property (nonatomic, strong) NSString *userName;
@property (nonatomic, strong) NSString *avatarURL;
@property (nonatomic, strong) NSString *email;
@property (nonatomic) NSTimeInterval lastLogonTime;

/**
 *  Init a person with parameters. The key for each value in dictionary is a constant.
        For example: YLPersonInfoUserIDKey, YLPersonInfoUserNameKey... See YLPersonInfo.h for more details.
 *
 *  @param params A dictionary contains data for the person.
 *
 *  @return A new initialized object.
 */
- (id)initWithParameters:(NSDictionary *)params;

/**
 *  Update person information with parameters.
    The key for each value in dictionary is a constant.
 
    For example: YLPersonInfoUserIDKey, YLPersonInfoUserNameKey... See YLPersonInfo.h for more details.
 *
 *  @param params A dictionary containts new data for the person.
 */
- (void)updateWithParameters:(NSDictionary *)params;

/**
 *  Export person data to dictionary. Each object in dictionary is identified by a constant key.
        For example: YLPersonInfoUserIDKey, YLPersonInfoUserNameKey... See YLPersonInfo.h for more details.
 *
 *  @return A new created dictionary contains user data.
 */
- (NSDictionary *)exportToDictionary;

@end
