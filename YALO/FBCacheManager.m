//
//  FBCacheManager.m
//  FacebookContact
//
//  Created by VanDao on 7/27/16.
//  Copyright © 2016 VNG Corp. All rights reserved.
//

#import "FBCacheManager.h"
#import "mach/mach.h"
#import "mach/mach_host.h"
#define kPercentOfUsableMemoryCacheWithFreeMemory 0.5
#define kPercentOfUsageMemoryCacheForWarning 0.9

@interface FBCacheManager ()

@property NSMutableDictionary *cacheMemory;
@property dispatch_queue_t internalSerialQueue;
@property NSInteger currentSize;

@end

@implementation FBCacheManager

+ (id)sharedCache {
    
    static FBCacheManager *singletonCache = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        
        singletonCache = [[self alloc] init];
    });
    
    return singletonCache;
}

- (id)init {
    
    self = [super init];
    if (!self)
        return nil;
    
    _cacheMemory = [[NSMutableDictionary alloc] init];
    _internalSerialQueue = dispatch_queue_create("com.vng.FBImageCachingQueue", DISPATCH_QUEUE_SERIAL);
    _cacheSize = [FBCacheManager getAvailableMemory] * kPercentOfUsableMemoryCacheWithFreeMemory;
    _currentSize = 0;
    
    return self;
}

- (void)cacheImage:(UIImage *)image forKey:(NSString *)aKey {
    
    if (image == nil || aKey == nil)
        return;
    
    FBImageCacheItem *cacheItem = [[FBImageCacheItem alloc]initWithImage:image forKey:aKey];
    
    dispatch_async(_internalSerialQueue, ^{
        [_cacheMemory setObject:cacheItem forKey:aKey];
    });

    _currentSize += cacheItem.sizeOfItem;
    
    if ([self checkMemoryWarning]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:[NSString stringWithFormat:@"%@", kNotificationWarningMemory] object:nil];
    }
}

- (UIImage *)imageForKey:(NSString *)aKey {
    
    __block FBImageCacheItem *returnedItem;
    
    dispatch_sync(_internalSerialQueue, ^{
        
        returnedItem = [_cacheMemory objectForKey:aKey];
        
        if (returnedItem)
            [returnedItem updateFocusDate];
    });
    
    return returnedItem ? returnedItem.image : nil;
}

- (void)removeItemForKey:(NSString *)aKey {
    
    dispatch_async(_internalSerialQueue, ^{
        
        FBImageCacheItem *item = [_cacheMemory objectForKey:aKey];
        
        if (item) {
            _currentSize -= item.sizeOfItem;
            [_cacheMemory removeObjectForKey:aKey];
        }
    });
}

- (void)removeAllImages {
    
    dispatch_async(_internalSerialQueue, ^{
        
        [_cacheMemory removeAllObjects];
        _currentSize = 0;
    });
}

- (BOOL)checkMemoryWarning {
    
    return _cacheSize * kPercentOfUsageMemoryCacheForWarning > _currentSize;
}

- (void)removeItemsSinceDate:(nonnull NSDate *)date {
    
    dispatch_async(_internalSerialQueue, ^{
        for (NSString *key in [_cacheMemory allKeys]) {
            
            FBImageCacheItem *item = [_cacheMemory objectForKey:key];
            if ([item.lastFocusDate compare:date] == NSOrderedDescending) {
                
                [_cacheMemory removeObjectForKey:key];
            }
        }
    });
}

- (void)removeItemsBeforDate:(nonnull NSDate *)date {
    
    dispatch_async(_internalSerialQueue, ^{
        for (NSString *key in [_cacheMemory allKeys]) {
            
            FBImageCacheItem *item = [_cacheMemory objectForKey:key];
            if ([item.lastFocusDate compare:date] == NSOrderedAscending) {
                
                [_cacheMemory removeObjectForKey:key];
            }
        }
    });
}

- (void)removeOutOfDateItems {
    
    dispatch_async(_internalSerialQueue, ^{
        for (NSString *key in [_cacheMemory allKeys]) {
            
            FBImageCacheItem *item = [_cacheMemory objectForKey:key];
            if ([item isItemOutOfDate]) {
                
                [_cacheMemory removeObjectForKey:key];
            }
        }
    });
}

+ (unsigned int) getAvailableMemory {
    
    natural_t mem_free;
    
    mach_port_t host_port;
    mach_msg_type_number_t host_size;
    vm_size_t pagesize;
    
    host_port = mach_host_self();
    host_size = sizeof(vm_statistics_data_t) / sizeof(integer_t);
    host_page_size(host_port, &pagesize);
    
    vm_statistics_data_t vm_stat;
    
    if (host_statistics(host_port, HOST_VM_INFO, (host_info_t)&vm_stat, &host_size) != KERN_SUCCESS) {
        NSLog(@"Failed to fetch vm statistics");
    }
    
    /* Stats in bytes */
    mem_free = vm_stat.free_count * (unsigned int) pagesize;
    
    return mem_free;
}

@end
