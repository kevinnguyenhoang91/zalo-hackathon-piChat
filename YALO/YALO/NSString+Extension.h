//
//  NSString+Extension.h
//  YALO
//
//  Created by qhcthanh on 8/12/16.
//  Copyright © 2016 admin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Extension)


/**
 *  Get bounding Rect of NSString with NSStringDrawingUsesLineFragmentOrigin Option and Content null
 *
 *  @param size The size bounding of NSString
 *  @param font The font of NSString will display in UI
 *
 *  @return The size of NSString in bound
 */
- (CGSize)boundingRectWithSize:(CGSize)size withFont:(UIFont *)font;

@end
