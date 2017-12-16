//
//  UIImage+Resize.m
//  YALO
//
//  Created by qhcthanh on 8/1/16.
//  Copyright © 2016 admin. All rights reserved.
//

#import "UIImage+Resize.h"

@implementation UIImage (Resize)


- (UIImage *)scaleWithSize:(CGSize)newSize {
    UIGraphicsBeginImageContext(newSize);
    
    [self drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return newImage;
}

@end
