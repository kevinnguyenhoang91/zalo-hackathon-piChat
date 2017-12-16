//
//  YLUserInfoCollectionViewCell.h
//  YALO
//
//  Created by BaoNQ on 8/5/16.
//  Copyright © 2016 admin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YLPerson.h"

@interface YLUserInfoCollectionViewCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UIImageView *memberPhoto;
@property (weak, nonatomic) IBOutlet UILabel *memberName;

/**
 *  Binding UI with YLPersonProtocol.
 *
 *  @param protocol The protocol model to bind data.
 */
- (void)bindDataWithProtocol:(id<YLPersonProtocol>) protocol;

@end
