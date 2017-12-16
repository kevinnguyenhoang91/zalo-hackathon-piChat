//
//  NSDate+Format.h
//  YALO
//
//  Created by qhcthanh on 8/2/16.
//  Copyright © 2016 admin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (Format)

+ (NSString *)convertToStringWithTimeIntervalSince1970:(NSTimeInterval)timeInterval;

@end
