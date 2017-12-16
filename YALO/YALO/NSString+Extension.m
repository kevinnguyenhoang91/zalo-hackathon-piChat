//
//  NSString+Extension.m
//  YALO
//
//  Created by qhcthanh on 8/12/16.
//  Copyright © 2016 admin. All rights reserved.
//

#import "NSString+Extension.h"

@implementation NSString (Extension)

- (CGSize)boundingRectWithSize:(CGSize)size withFont:(UIFont *)font {
    return [self boundingRectWithSize:size
                       options:NSStringDrawingUsesLineFragmentOrigin
                               attributes:@{NSFontAttributeName:font}
                                  context:nil].size;
}

@end
