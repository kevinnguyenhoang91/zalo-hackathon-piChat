//
//  MessageViewController.m
//  YALO
//
//  Created by qhcthanh on 7/28/16.
//  Copyright © 2016 admin. All rights reserved.
//

#import "MessageViewController.h"
#import "CreateGroupChatViewController.h"
#import "YLExtDefines.h"
#import "YLPerson.h"
#import "GroupSettingViewController.h"
#import "YLNavigationController.h"

#define kMessageTextBoundingSize CGSizeMake(220.0f, CGFLOAT_MAX)

@interface MessageViewController () <UITextViewDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate>

// UI properties
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *heightChatConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomChatToolbarConstraint;
@property (weak, nonatomic) IBOutlet UITextView *chatTextView;
@property (weak, nonatomic) IBOutlet UIView *chatToolbarView;
@property (weak, nonatomic) IBOutlet UICollectionView *chatCollectionView;
@property (weak, nonatomic) IBOutlet UIImageView *sendMessageButton;

// Private properties
@property CGSize keyboardSize;
@property CGFloat lastContentSizeHeight;
@property BOOL isFirstLoad;

@end

@implementation MessageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Notification addObserver
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didKeyBoardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didKeyBoardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(observeMessageFromGroupWithNotifcation:) name:kNotificationNewMessageObserved object:nil];
    
    // Setup current textView Height
    _lastContentSizeHeight = _chatTextView.contentSize.height;
    _chatTextView.text = kMessageBoxPlaceholder;
    
    // Get send and receive message Nib
    UINib *sendNib = [UINib nibWithNibName:kChatSendCellNibName bundle:nil];
    UINib *receiveNib = [UINib nibWithNibName:kChatReceiveCellNibName bundle:nil];
    
    // Register Nib Chat Message
    [_chatCollectionView registerNib:receiveNib forCellWithReuseIdentifier:kChatReceiveCellResueIdentifier];
    [_chatCollectionView registerNib:sendNib forCellWithReuseIdentifier:kChatSendCellResueIdentifier];
    
    // Set default properties
    self.navigationItem.title = self.groupChat.groupName;
    _sendMessageButton.userInteractionEnabled = false;
     _isFirstLoad = YES;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    // Update last seen group to data and model
    [self.groupChat setLastSeenMessageTime:[[NSDate new] timeIntervalSince1970]];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    // Scroll to bottom message if have message and is first load message
    if (self.groupChat._messages.count != 0 && _isFirstLoad) {
        [_messageCollectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:self.groupChat._messages.count-1 inSection:0] atScrollPosition:UICollectionViewScrollPositionBottom animated:NO];
        
        // The variable determine just scroll to bottom when first time open this controller
        _isFirstLoad = NO;
    }
}

- (void)dealloc {
    // Remove notification observer
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - NSNotificationKeyBoard

- (void)didKeyBoardWillShow:(NSNotification *)notifiaction {
    // Get keyboardSize
    self.keyboardSize = [[[notifiaction userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    // Update contrainst ChatToolBar
    _bottomChatToolbarConstraint.constant = _keyboardSize.height;
    
    // Animation show keyboard
    [UIView animateWithDuration:0.3 animations:^{
        [self.view layoutIfNeeded];
    } completion:^(BOOL finsish){
        // If finish animation keyboard scroll to bottom
        if(finsish && [_messageCollectionView numberOfItemsInSection:0] > 0) {
            NSIndexPath* newMessageIndexPath = [NSIndexPath indexPathForItem:[_messageCollectionView numberOfItemsInSection:0] - 1 inSection:0];
            
            [_messageCollectionView scrollToItemAtIndexPath:newMessageIndexPath atScrollPosition:UICollectionViewScrollPositionBottom animated:true];
        }
    }];
}

- (void)didKeyBoardWillHide:(NSNotification *)notifiaction {
    // Update contrainst ChatToolBar
    _bottomChatToolbarConstraint.constant = 0;
    
    // Animation when keyboard hide
    [UIView animateWithDuration:0.3 animations:^{
        [self.view layoutIfNeeded];
    }];
}

#pragma mark - NSNotificationGroupMessage

- (void)observeMessageFromGroupWithNotifcation:(NSNotification *)notification {
    // Get current number cell in messageCollectionView
    NSInteger currentItemInCollection = [_messageCollectionView numberOfItemsInSection:0];
    
    // Check if is new message insert indexPath
    if (currentItemInCollection != self.groupChat._messages.count) {
        // Add new message to first collectionView
        NSIndexPath* newMessageIndexPath = [NSIndexPath indexPathForItem:currentItemInCollection inSection:0];
        
        [_messageCollectionView insertItemsAtIndexPaths:@[newMessageIndexPath]];
        
        // Scroll to bottom
        [_messageCollectionView scrollToItemAtIndexPath:newMessageIndexPath atScrollPosition:UICollectionViewScrollPositionBottom animated:true];
    }
}

#pragma mark - IBAction

- (IBAction)backAction:(id)sender {
    YLNavigationController *navigationController = (YLNavigationController *)self.navigationController;
    
    [navigationController popToRootViewController:self animated:true completion:^{
       // do anything ...
    }];
}

- (IBAction)addFriendAction:(id)sender {
    // Push to group setting ViewController with current group in this viewcontroller
    GroupSettingViewController *settingVC = [self.storyboard instantiateViewControllerWithIdentifier:NSStringFromClass([GroupSettingViewController class])];
    settingVC.groupInfo = self.groupChat;
    
    [self.navigationController pushViewController:settingVC animated:YES];
}


- (IBAction)sendMessage:(id)sender {
    // Send message with content _chatTextView.text and attachment nil. This func will push message to server and add to list message in group
    // Maybe delay (1~2)s to push message if weak connection
    [self.groupChat pushMessageWithContent:_chatTextView.text attachment:nil];

    // Clean message and state of _chatTextView and _heightChatConstraint
    [self textView:_chatTextView shouldChangeTextInRange:NSMakeRange(0, _chatTextView.text.length) replacementText:@""];
    _chatTextView.text = @"";
    
    // Update state of textView
    [self textViewDidChange:_chatTextView];
}

- (void)sendMessageWithImage:(UIImage *)imageSent {
    // Convert UIImage to NSData then NSData to NSString
    NSData *dataImage = [[NSData alloc] init];
    dataImage = UIImageJPEGRepresentation(imageSent, 0.8);
    NSString *stringImage = [dataImage base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
    
    // Push message with attachement
    [self.groupChat pushMessageWithContent:@"" attachment:stringImage];
}

- (IBAction)openPhoto:(id)sender {
    // Int Alert sheet ... 3 option (Take Photo, Use Gallery, Cancel)
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:nil
                                                                   message:nil
                                                            preferredStyle:UIAlertControllerStyleActionSheet];
    
    // Take photo action
    UIAlertAction* takePhotoAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Take Photo", @"Message") style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
        if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
            
            UIAlertView *myAlertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", @"Message")
                                                                  message:NSLocalizedString(@"Device has no camera", @"Message")
                                                                 delegate:nil
                                                        cancelButtonTitle:@"OK"
                                                        otherButtonTitles: nil];
            [myAlertView show];
        }
        else {
            UIImagePickerController *picker = [[UIImagePickerController alloc] init];
            picker.delegate = self;
            picker.sourceType = UIImagePickerControllerSourceTypeCamera;
            
            [self presentViewController:picker animated:YES completion:NULL];
        }
    }];
    
    // Select photo in gallery action
    UIAlertAction* selectPhotoAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Select Photo", @"Message") style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.delegate = self;
        picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        
        [self presentViewController:picker animated:YES completion:NULL];
    }];
    
    // Cacncel dissmiss alert
    UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", @"Message") style:UIAlertActionStyleCancel handler:^(UIAlertAction * action) {
        [alert dismissViewControllerAnimated:YES completion:^{}];
    }];
    
    // Add action to alert view controller
    [alert addAction:takePhotoAction];
    [alert addAction:selectPhotoAction];
    [alert addAction:cancelAction];
    
    [self presentViewController:alert animated:YES completion:nil];
}

- (IBAction)openMicro:(id)sender {
    
}

- (IBAction)didTapCollectionView:(id)sender {
    // Dissmiss keyboard
    [_chatTextView resignFirstResponder];
}

#pragma mark - UIImagePickerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    // Get image and scale
    UIImage* imagePicked = [info objectForKey:UIImagePickerControllerOriginalImage];
    imagePicked = [imagePicked scaleWithSize:CGSizeMake(400, 600)];
    
    // Send message with attachment
    [self sendMessageWithImage:imagePicked];
    
    // Dissmiss ImagePickerViewController
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    // Dissmiss ImagePickerViewController
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

#pragma mark - TextViewDelegate

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    static NSInteger currentLine = 1;
    
    // Current text in textview
    NSString *newText = [textView.text stringByReplacingCharactersInRange:range withString:text];
    
    // Calculate text width with font in textView
    CGFloat textWidth = CGRectGetWidth(UIEdgeInsetsInsetRect(textView.frame, textView.textContainerInset));
    CGSize sizeText = [newText sizeWithAttributes:@{NSFontAttributeName:textView.font}];
    textWidth = sizeText.width + 16;
    
    // Caclculate line with bound textView.width
    NSInteger numberOfLines = textWidth / textView.contentSize.width + 1;
    CGFloat deltaLineHeight = textView.font.lineHeight * (numberOfLines - currentLine);
    
    // deltaLineHeight is not equal 0 will update _heightChatConstraint
    // Height update is textView.font.lineHeight + 5 (edge top) multi line change
    // (numberOfLines - currentLine) is line change
    // Update current line if line change
    if (deltaLineHeight != 0) {
        _heightChatConstraint.constant += (textView.font.lineHeight + 5) * (numberOfLines - currentLine);
        
        currentLine = numberOfLines;
        [textView setContentOffset:CGPointZero];
        [textView layoutIfNeeded];
    }
    
    return true;
}

- (void)textViewDidChange:(UITextView *)textView {
    // Check current state of textView
    // If have text in textView state is active - Enable _sendMessageButton and _sendMessageButton image = kSendPinkImage
    // Else disable _sendMessageButton and _sendMessageButton image = kSendGrayImage
    if ([textView.text isEqualToString:@""]) {
        _sendMessageButton.image = kSendGrayImage;
        _sendMessageButton.userInteractionEnabled = false;
    } else {
        _sendMessageButton.image = kSendPinkImage;
        _sendMessageButton.userInteractionEnabled = true;
    }
}

- (void)textViewDidBeginEditing:(UITextView *)textView {
    // Remove placeholder if current text in textView is kMessageBoxPlaceholder
    if ([textView.text isEqualToString:kMessageBoxPlaceholder]) {
        textView.text = @"";
    }
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    // Set kMessageBoxPlaceholder to textView.text if current text in textView is empty
    if ([textView.text isEqualToString:@""]) {
        textView.text = kMessageBoxPlaceholder;
    }
}

#pragma mark - UICollectionViewDelegate + UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.groupChat._messages.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    // Get message in group with indexPath.row cell
    YLMessageDetail *message = [self.groupChat._messages objectAtIndex:indexPath.row];
    
    // Received message cell if message.userID is not currentUser.userID
    NSString *cellReuseIdentifier = [message.userID isEqualToString:[YLUserInfo sharedUserInfo].userID] ? kChatSendCellResueIdentifier : kChatReceiveCellResueIdentifier;
    YLChatCollectionViewCell* chatCell = (YLChatCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:cellReuseIdentifier forIndexPath:indexPath];
    
    // Binding UI with YLMessageProtocol
    [chatCell bindingUIWithProtocol:(id<YLMessageProtocol>)message];
    
    return chatCell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    // Get message in indexPath
    YLMessageDetail *message = [self.groupChat._messages objectAtIndex:indexPath.row];
    
    // Find the required cell height
    //CGFloat nameSize = [message.userID boundingRectWithSize:kMessageTextBoundingSize withFont:kNameUserFontInChatMessageCell].height;
    CGFloat messageHeight = [message.content boundingRectWithSize:kMessageTextBoundingSize withFont:kTimeFontInChatMessageCell].height;
    CGFloat timeHeight = [@"00:00" boundingRectWithSize:kMessageTextBoundingSize withFont:kMessageFontInChatMessageCell].height;
    
    // MessageCell Height = messageHeight + time Height + default height
    // 45 is default size
    CGFloat cellHeight = /*nameSize.height +*/ messageHeight + timeHeight + 45.0f;
    
    // If has attachment, height will increase kAttachmentHeightDefaultInMessageCell
    if (message.attachment && [message.attachment isEqualToString:kAttachmentTypeImage]) {
        cellHeight += kAttachmentHeightDefaultInMessageCell;
    }
    
    return CGSizeMake(CGRectGetMaxX(collectionView.frame), cellHeight);
}

@end



