//
//  FBImageCacheItem.h
//  FacebookContact
//
//  Created by VanDao on 7/25/16.
//  Copyright © 2016 VNG Corp. All rights reserved.
//

#import <Foundation/Foundation.h>
#define kTimeToLive 1 * 24 * 60 * 60 //1 day
@import UIKit;

@interface FBImageCacheItem : NSObject

@property (readonly, strong, nonatomic) UIImage *image;
@property (readonly, strong, nonatomic) NSString *key;
@property (readonly, strong, nonatomic) NSDate *lastFocusDate;
@property (readonly, assign) NSInteger sizeOfItem;

/**
 *  Initializes an `FBImageCacheItem` object with the specified image
 *
 *  @param image The image for the item
 *
 *  @return The newly-initialized image cache item
 */
- (id)initWithImage:(UIImage *)image forKey:(NSString *)aKey;

/**
 *  Update lastFocusDate with current date
 */
- (void)updateFocusDate;

/**
 *  Check if lastFocusDate is out of date
 *
 *  @return YES if CacheItem is out of date, otherwise, return NO.
 */
- (BOOL)isItemOutOfDate;

/**
 *  Check if lastForcusDate is out of date
 *
 *  @param date The expired time of CacheItem
 *
 *  @return YES if CacheItem is out of date, otherwise, return NO
 */
- (BOOL)isItemOutOfDateWithExpiredDate:(NSDate *)date;

@end
