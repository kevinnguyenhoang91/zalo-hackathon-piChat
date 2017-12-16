//
//  FBCacheManager.h
//  FacebookContact
//
//  Created by VanDao on 7/27/16.
//  Copyright © 2016 VNG Corp. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FBImageCacheItem.h"

/**
 *  Key name to observer notification from notifycation center.
 *  The cache will post notify when used memory is more than 70% of cache memory
 *
 */
static const NSString * kNotificationWarningMemory = @"MEMORY WARNING";

@interface FBCacheManager : NSObject

@property (assign, readonly) NSInteger cacheSize;

/**
 *  Singletion method of cache.
 */
+ (instancetype)sharedCache;

/**
 *  Add an item associated with aKey to cache
 *
 *  @param item An item for aKey
 *               Raises an NSInvalidArgumentException if anObject is nil. If you need to represent a nil value in the dictionary, use NSNull.
 *  @param aKey  The key for value. The key is copied (using copyWithZone:; keys must conform to the NSCopying protocol). If aKey already exists in the cache, image takes its place.
 */
- (void)cacheImage:(UIImage *)image forKey:(NSString *)aKey;

/**
 *  Returns the value associated with a given key.
 *  The value associated with aKey, or nil if no value is associated with aKey.
 *
 *  @param aKey The key for which to return the corresponding value.
 *
 *  @return The image in cache which associated with aKey
 */
- (UIImage *)imageForKey:(NSString *)aKey;

/**
 *  Remove an image from cache associated with aKey
 *  Does nothing if aKey does not exist
 *
 *  @param aKey The key to remove
 */
- (void)removeImageForKey:(NSString *)aKey;

/**
 *  Remove all images from cache
 */
- (void)removeAllImages;

/**
 *  Clears the given cache of any items since the provide date.
 *
 *  @param date The provide date
 */
- (void)removeImagesSinceDate:(NSDate *)date;

/**
 *  Clears the given cache of any items before the provide date.
 *
 *  @param date The provide date
 */
- (void)removeImagesBeforDate:(NSDate *)date;

/**
 *  Clear the given cache of any items are out of date
 */
- (void)removeOutOfDateImages;

/**
 *  Determine and notice if percent of current usage memory out of memory capacity is more than 90%
 *
 *  @return YES if the percent is more than 90%, otherwise, return NO
 */
- (BOOL)checkMemoryWarning;

@end
