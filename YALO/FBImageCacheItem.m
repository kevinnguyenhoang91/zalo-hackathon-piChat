//
//  FBImageCacheItem.m
//  FacebookContact
//
//  Created by VanDao on 7/25/16.
//  Copyright © 2016 VNG Corp. All rights reserved.
//

#import "FBImageCacheItem.h"

@implementation FBImageCacheItem

- (id)initWithImage:(UIImage *)image forKey:(NSString *)aKey {
    self = [super init];
    
    if (self) {
        _image = image;
        _key = aKey;
        _sizeOfItem = CGImageGetBytesPerRow(image.CGImage) * CGImageGetHeight(image.CGImage);
        _lastFocusDate = [NSDate date];
    }
    
    return self;
}

- (void)updateFocusDate {
    
    _lastFocusDate = [NSDate date];
}

- (BOOL)isItemOutOfDate {
    
    return ([NSDate timeIntervalSinceReferenceDate] - [_lastFocusDate timeIntervalSinceReferenceDate]) > kTimeToLive;
}

- (BOOL)isItemOutOfDateWithExpiredDate:(NSDate *)date {
    
    return ([date timeIntervalSinceReferenceDate] - [_lastFocusDate timeIntervalSinceReferenceDate]) > kTimeToLive;
}

@end
