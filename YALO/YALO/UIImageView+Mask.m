//
//  UIImageView+Mask.m
//  ZaloContact
//
//  Created by qhcthanh on 6/1/16.
//  Copyright © 2016 qhcthanh. All rights reserved.
//

#import "UIImageView+Mask.h"


@implementation UIImageView (Mask)

-(void)maskAvatarCircle:(CGRect)frame {
    CALayer *mask = [CALayer layer];
    mask.contents = (id)[[UIImage imageNamed:@"mask-circle-avatar-large60"] CGImage];
    mask.frame = frame;
    
    self.layer.mask = mask;
    self.layer.masksToBounds = YES;
}

@end
