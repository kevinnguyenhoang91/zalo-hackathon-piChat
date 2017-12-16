//
//  MessageViewController.h
//  YALO
//
//  Created by qhcthanh on 7/28/16.
//  Copyright © 2016 admin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YLGroupChat.h"
#import "UIImage+Resize.h"
#import "YLChatCollectionViewCell.h"
#import "NSString+Extension.h"

#define kMessageBoxPlaceholder NSLocalizedString(@"Send message", @"Message")

#define kSendGrayImage [UIImage imageNamed:@"SendGray"]
#define kSendPinkImage [UIImage imageNamed:@"SendPink"]

#define kChatSendCellNibName @"ChatSendCell"
#define kChatReceiveCellNibName @"ChatReceiveCell"
#define kChatSendCellResueIdentifier @"YLChatSendCell"
#define kChatReceiveCellResueIdentifier @"YLChatReceiveCell"

@interface MessageViewController : UIViewController

@property (weak, nonatomic) IBOutlet UICollectionView *messageCollectionView;

@property (weak) YLGroupChat* groupChat;

@end