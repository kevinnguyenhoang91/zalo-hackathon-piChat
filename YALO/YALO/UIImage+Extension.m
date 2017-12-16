//
//  UIImage+Contact.m
//  ZaloContactInviting
//
//  Created by VanDao on 6/6/16.
//  Copyright © 2016 VanDao. All rights reserved.
//

#import "UIImage+Extension.h"
#define ARC4RANDOM_MAX      0x100000000

@implementation UIImage (Extension)

+ (UIImage * _Nonnull)createImageFromLetters:(NSString * _Nullable)displayString{
    if (displayString == nil)
        displayString = @"";
    
    CGFloat height = 40;
    srand48(arc4random());
    CGFloat fontSize = height * 0.5f;
    
    NSDictionary *textAttributes = @{
                                     NSFontAttributeName: [UIFont systemFontOfSize:fontSize weight:0.4],
                                     NSForegroundColorAttributeName:[UIColor whiteColor]
                                     };
    UIColor *backgroundColor = [UIColor colorWithRed:240.0/255 green:98.0/255 blue:146.0/255 alpha:1.0f];
    CGFloat scale = [UIScreen mainScreen].scale;
    CGSize size = CGSizeMake(height, height);
    
    //Begin create image
    UIGraphicsBeginImageContextWithOptions(size, NO, scale);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    //Clip context to a circle
    CGPathRef path = CGPathCreateWithEllipseInRect(CGRectMake(0, 0, height, height), NULL);
    CGContextAddPath(context, path);
    CGContextClip(context);
    CGPathRelease(path);
    
    //Fill backgrond of context
    CGContextSetFillColorWithColor(context, backgroundColor.CGColor);
    CGContextFillRect(context, CGRectMake(0, 0, size.width, size.height));
    CGSize textSize = [displayString sizeWithAttributes:textAttributes];
    [displayString drawInRect:CGRectMake(height/2 - textSize.width/2,
                                         height/2 - textSize.height/2,
                                         textSize.width,
                                         textSize.height)
               withAttributes:textAttributes];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

+ (UIImage * _Nonnull)clipToCircleImage:(UIImage * _Nonnull)image withMask:(UIImage * _Nonnull)maskImage{
    if (image == nil || maskImage == nil)
        return nil;
    
    CGImageRef maskRef = maskImage.CGImage;
    
    CGImageRef mask = CGImageMaskCreate(CGImageGetWidth(maskRef),
                                        CGImageGetHeight(maskRef),
                                        CGImageGetBitsPerComponent(maskRef),
                                        CGImageGetBitsPerPixel(maskRef),
                                        CGImageGetBytesPerRow(maskRef),
                                        CGImageGetDataProvider(maskRef), NULL, false);
    
    CGImageRef maskedImageRef = CGImageCreateWithMask([image CGImage], mask);
    UIImage *maskedImage = [UIImage imageWithCGImage:maskedImageRef];
    
    CGImageRelease(mask);
    CGImageRelease(maskedImageRef);
    
    return maskedImage;
}

+ (UIImage * _Nonnull)createImageFromThreeImageWithFirstImage:(UIImage * _Nonnull)image1 secondImage:(UIImage * _Nonnull)image2 thirdImage:(UIImage * _Nonnull)image3 withSize:(CGSize)imageSize {
    
    //Begin create image
    UIGraphicsBeginImageContextWithOptions(imageSize, NO, 1.0);
    CGContextRef context = UIGraphicsGetCurrentContext();

    CGContextTranslateCTM(context, 0, imageSize.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    
    //Draw first image
    CGRect firstImageRect = CGRectMake(imageSize.width/4, imageSize.height/2, imageSize.width/2, imageSize.height/2);
    UIImage *circleImage1 = [self clipToCircleImage:image1 withMask:[UIImage imageNamed:@"mask4"]];
    CGContextDrawImage(context, firstImageRect, circleImage1.CGImage);
    
    //Draw second image
    CGRect secondImageRect = CGRectMake(0, 0, imageSize.width/2, imageSize.height/2);
    UIImage *circleImage2 = [self clipToCircleImage:image2 withMask:[UIImage imageNamed:@"mask4"]];
    CGContextDrawImage(context, secondImageRect, circleImage2.CGImage);
    
    //Draw third image
    CGRect thirdImageRect = CGRectMake(imageSize.width/2, 0, imageSize.width/2, imageSize.height/2);
    UIImage *circleImage3 = [self clipToCircleImage:image3 withMask:[UIImage imageNamed:@"mask4"]];
    CGContextDrawImage(context, thirdImageRect, circleImage3.CGImage);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

- (void)drawInRect:(CGRect)rect contextSize:(CGSize)size{
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);
    
    CGContextDrawImage(context, rect, self.CGImage);
    
    CGContextRestoreGState(context);
}

+ (UIImage *)flipImageByVertically:(UIImage *)imageSrc {
    //Begin create image
    UIGraphicsBeginImageContext(imageSrc.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextRotateCTM(context, M_PI);
    [imageSrc drawAtPoint:CGPointZero];
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

+ (UIImage * _Nonnull)createImageFromFourImageWithFirstImage:(UIImage * _Nonnull)image1 secondImage:(UIImage * _Nonnull)image2 thirdImage:(UIImage * _Nonnull)image3 fourthImage:(UIImage * _Nonnull)image4 withSize:(CGSize)imageSize {
    
    //Begin create image
    UIGraphicsBeginImageContextWithOptions(imageSize, NO, 1.0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextTranslateCTM(context, 0, imageSize.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    
    //Draw first image
    CGRect firstImageRect = CGRectMake(0, imageSize.height/2, imageSize.width/2, imageSize.height/2);
    UIImage *circleImage1 = [self clipToCircleImage:image1 withMask:[UIImage imageNamed:@"mask4"]];
    CGContextDrawImage(context, firstImageRect, circleImage1.CGImage);
    
    //Draw second image
    CGRect secondImageRect = CGRectMake(imageSize.width/2, imageSize.height/2, imageSize.width/2, imageSize.height/2);
    UIImage *circleImage2 = [self clipToCircleImage:image2 withMask:[UIImage imageNamed:@"mask4"]];
    CGContextDrawImage(context, secondImageRect, circleImage2.CGImage);
    
    //Draw third image
    CGRect thirdImageRect = CGRectMake(0, 0, imageSize.width/2, imageSize.height/2);
    UIImage *circleImage3 = [self clipToCircleImage:image3 withMask:[UIImage imageNamed:@"mask4"]];
    CGContextDrawImage(context, thirdImageRect, circleImage3.CGImage);
    
    //Draw fourth image
    CGRect fourthImageRect = CGRectMake(imageSize.width/2, 0, imageSize.width/2, imageSize.height/2);
    UIImage *circleImage4 = [self clipToCircleImage:image4 withMask:[UIImage imageNamed:@"mask4"]];
    CGContextDrawImage(context, fourthImageRect, circleImage4.CGImage);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

@end
