//
//  UIImage+Contact.h
//  ZaloContactInviting
//
//  Created by VanDao on 6/6/16.
//  Copyright © 2016 VanDao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface UIImage (Extension)

/**
 *  Create an UIImage Object by first letters of person's name.
 *
 *  @param letters NSString contain firest letters of given name and family name of person
 *
 *  @return UIImage
 */
+ (UIImage * _Nonnull)createImageFromLetters:(NSString * _Nullable)letters;

/**
 *  Crop an rectange image to circle image using circle mask image
 *
 *  @param mask Original image
 *
 *  @return Circle mask image
 */
+ (UIImage * _Nonnull)clipToCircleImage:(UIImage * _Nonnull)image withMask:(UIImage * _Nonnull)maskImage;

/**
 *  Create an image from three sub-image
 *
 *  @param image1 The first image
 *  @param image2 The second image
 *  @param image3 The third image
 *  @param imageSize The size of result image
 *
 *  @return The result image
 */
+ (UIImage * _Nonnull)createImageFromThreeImageWithFirstImage:(UIImage * _Nonnull)image1 secondImage:(UIImage * _Nonnull)image2 thirdImage:(UIImage * _Nonnull)image3 withSize:(CGSize)imageSize;

/**
 *  Create an image from four sub-image
 *
 *  @param image1 The first image
 *  @param image2 The second image
 *  @param image3 The third image
 *  @param image4 The fourth image
 *  @param iamgeSize The size of result image
 *
 *  @return The result image
 */
+ (UIImage * _Nonnull)createImageFromFourImageWithFirstImage:(UIImage * _Nonnull)image1 secondImage:(UIImage * _Nonnull)image2 thirdImage:(UIImage * _Nonnull)image3 fourthImage:(UIImage * _Nonnull)image4 withSize:(CGSize)imageSize;

/**
 *  Draw image in rect of context
 *
 *  @param rect The frame of image in context
 *  @param size The size of context
 */
- (void)drawInRect:(CGRect)rect contextSize:(CGSize)size;

@end
