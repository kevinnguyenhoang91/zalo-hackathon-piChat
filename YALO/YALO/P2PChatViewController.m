//
//  MessageViewController.m
//  YALO
//
//  Created by qhcthanh on 7/28/16.
//  Copyright © 2016 admin. All rights reserved.
//

#import "P2PChatViewController.h"
#import "CreateGroupChatViewController.h"
#import "YLExtDefines.h"
#import "YLPerson.h"
#import "GroupSettingViewController.h"
#import "YLNavigationController.h"
#import "Transcript.h"

#define kMessageTextBoundingSize CGSizeMake(220.0f, CGFLOAT_MAX)

@interface P2PChatViewController () <UITextViewDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate>

// UI properties
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *heightChatConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomChatToolbarConstraint;
@property (weak, nonatomic) IBOutlet UITextView *chatTextView;
@property (weak, nonatomic) IBOutlet UIView *chatToolbarView;
@property (weak, nonatomic) IBOutlet UICollectionView *chatCollectionView;
@property (weak, nonatomic) IBOutlet UIImageView *sendMessageButton;


// TableView Data source for managing sent/received messagesz
@property (retain, nonatomic) NSMutableArray *transcripts;
// Map of resource names to transcripts array index
@property (retain, nonatomic) NSMutableDictionary *imageNameIndex;


// Private properties
@property CGSize keyboardSize;
@property CGFloat lastContentSizeHeight;
@property BOOL isFirstLoad;

@end

@implementation P2PChatViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Notification addObserver
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didKeyBoardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didKeyBoardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    

    // Init transcripts array to use as table view data source
    _transcripts = [NSMutableArray new];
    _imageNameIndex = [NSMutableDictionary new];

    
    
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
    // Send the message
    Transcript *transcript = [self.sessionContainer sendMessage:_chatTextView.text];
    if (transcript) {
        [self insertTranscript:transcript];
    }
    // Clean message and state of _chatTextView and _heightChatConstraint
    [self textView:_chatTextView shouldChangeTextInRange:NSMakeRange(0, _chatTextView.text.length) replacementText:@""];
    _chatTextView.text = @"";
    
    // Update state of textView
    [self textViewDidChange:_chatTextView];
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
    
    [picker dismissViewControllerAnimated:YES completion:nil];
    
    // Don't block the UI when writing the image to documents
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        // We only handle a still image
        UIImage *imageToSave = (UIImage *)[info objectForKey:UIImagePickerControllerOriginalImage];
        
        // Save the new image to the documents directory
        NSData *pngData = UIImageJPEGRepresentation(imageToSave, 1.0);
        
        // Create a unique file name
        NSDateFormatter *inFormat = [NSDateFormatter new];
        [inFormat setDateFormat:@"yyMMdd-HHmmss"];
        NSString *imageName = [NSString stringWithFormat:@"image-%@.JPG", [inFormat stringFromDate:[NSDate date]]];
        // Create a file path to our documents directory
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *filePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:imageName];
        [pngData writeToFile:filePath atomically:YES]; // Write the file
        // Get a URL for this file resource
        NSURL *imageUrl = [NSURL fileURLWithPath:filePath];
        
        // Send the resource to the remote peers and get the resulting progress transcript
        Transcript *transcript = [self.sessionContainer sendImage:imageUrl];
        
        if (transcript) {
            transcript.image = imageToSave;
            
            // Add the transcript to the data source and reload
            dispatch_async(dispatch_get_main_queue(), ^{
                [self insertTranscript:transcript];
            });
        }
    });
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
    return _transcripts.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    // Get message in group with indexPath.row cell
    YLMessageDetail *message = [[YLMessageDetail alloc] init];
    
    // Get the transcript for this row
    Transcript *transcript = [self.transcripts objectAtIndex:indexPath.row];
    
    
    message.time = [[NSDate date] timeIntervalSince1970];
    message.content = transcript.message;
    if (transcript.image) {
        message.attachment = kAttachmentTypeImage;
        message.imageMsg = transcript.image;
    }
    
    // Received message cell if message.userID is not currentUser.userID
    NSString *cellReuseIdentifier = TRANSCRIPT_DIRECTION_SEND == transcript.direction ? kChatSendCellResueIdentifier : kChatReceiveCellResueIdentifier;
    YLChatCollectionViewCell* chatCell = (YLChatCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:cellReuseIdentifier forIndexPath:indexPath];
    
    // Binding UI with YLMessageProtocol
    [chatCell bindingUIWithProtocol:(id<YLMessageProtocol>)message];
    
    return chatCell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    // Get message in indexPath
    // Get message in group with indexPath.row cell
    YLMessageDetail *message = [[YLMessageDetail alloc] init];
    
    // Get the transcript for this row
    Transcript *transcript = [self.transcripts objectAtIndex:indexPath.row];
    
    
    message.time = [[NSDate date] timeIntervalSince1970];
    message.content = transcript.message;
    if (transcript.image) {
        message.attachment = kAttachmentTypeImage;
        message.imageMsg = transcript.image;
    }
    
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


#pragma mark - SessionContainerDelegate

- (void)receivedTranscript:(Transcript *)transcript
{
    // Add to table view data source and update on main thread
    dispatch_async(dispatch_get_main_queue(), ^{
        [self insertTranscript:transcript];
    });
}

- (void)updateTranscript:(Transcript *)transcript
{
    // Find the data source index of the progress transcript
    NSNumber *index = [_imageNameIndex objectForKey:transcript.imageName];
    NSUInteger idx = [index unsignedLongValue];
    // Replace the progress transcript with the image transcript
    [_transcripts replaceObjectAtIndex:idx withObject:transcript];
    
    // Reload this particular table view row on the main thread
    dispatch_async(dispatch_get_main_queue(), ^{
        NSIndexPath *newIndexPath = [NSIndexPath indexPathForItem:idx inSection:0];
        
        [self.chatCollectionView reloadItemsAtIndexPaths:@[newIndexPath]];
    });
}


// Helper method for inserting a sent/received message into the data source and reload the view.
// Make sure you call this on the main thread
- (void)insertTranscript:(Transcript *)transcript
{
    // Add to the data source
    [_transcripts addObject:transcript];
    
    // If this is a progress transcript add it's index to the map with image name as the key
    if (nil != transcript.progress) {
        NSNumber *transcriptIndex = [NSNumber numberWithUnsignedLong:(_transcripts.count - 1)];
        [_imageNameIndex setObject:transcriptIndex forKey:transcript.imageName];
    }
    
    // Update the table view
    NSIndexPath *newIndexPath = [NSIndexPath indexPathForItem:([self.transcripts count] - 1) inSection:0];
    
    [self.chatCollectionView insertItemsAtIndexPaths:@[newIndexPath]];
    
    // Scroll to the bottom so we focus on the latest message
    NSUInteger numberOfRows = [self.chatCollectionView numberOfItemsInSection:0];
    if (numberOfRows) {
        [self.chatCollectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:(numberOfRows - 1) inSection:0]
                                        atScrollPosition:UICollectionViewScrollPositionBottom
                                                animated:YES];
    }
}


@end



