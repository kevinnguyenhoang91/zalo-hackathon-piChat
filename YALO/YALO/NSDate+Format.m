//
//  NSDate+Format.m
//  YALO
//
//  Created by qhcthanh on 8/2/16.
//  Copyright © 2016 admin. All rights reserved.
//

#import "NSDate+Format.h"

// 1*60*60*24
#define kOneDayTimeInterval 86400

@implementation NSDate (Format)

+ (NSString *)convertToStringWithTimeIntervalSince1970:(NSTimeInterval)timeInterval {
    NSDate* dateParam = [[NSDate alloc] initWithTimeIntervalSince1970:timeInterval];
    
    NSDateFormatter* dateFormat = [NSDateFormatter new];
    dateFormat.dateFormat = @"HH:mm";
    
    NSTimeInterval timeIntervalBetweenNow = -[dateParam timeIntervalSinceNow];
    if (timeIntervalBetweenNow > kOneDayTimeInterval ) {
        NSInteger numberOfDay = timeIntervalBetweenNow/kOneDayTimeInterval;
        if (numberOfDay < 7) {
            return [NSString stringWithFormat:NSLocalizedString(@"%d days", @"Date"), numberOfDay];
        } else {
            dateFormat.dateFormat = @"dd/mm/yyyy";
        }
    }
    
    return [dateFormat stringFromDate:dateParam];
}



@end
