//
//  YLChatCollectionViewCell.h
//  YALO
//
//  Created by qhcthanh on 8/1/16.
//  Copyright © 2016 admin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YLMessageDetail.h"


#define kNameUserFontInChatMessageCell [UIFont fontWithName:@"Avenir-Black" size:16]
#define kMessageFontInChatMessageCell [UIFont fontWithName:@"Avenir-Book" size:14]
#define kTimeFontInChatMessageCell [UIFont fontWithName:@"Avenir-Light" size:13]

#define kAttachmentHeightDefaultInMessageCell 250

@interface YLChatCollectionViewCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UILabel *chatNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *chatMessageLabel;
@property (weak, nonatomic) IBOutlet UILabel *chatTimeLabel;
@property (weak, nonatomic) IBOutlet UIImageView *chatUserImage;
@property (weak, nonatomic) IBOutlet UIImageView *chatImageView;

/**
 *  Binding UI with YLMessageProtocol
 *
 *  @param protocol The protocol model to binding with UI
 */
-(void) bindingUIWithProtocol:(id<YLMessageProtocol>)protocol;

@end
