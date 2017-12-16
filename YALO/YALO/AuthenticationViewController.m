//
//  ViewController.m
//  FireChat
//
//  Created by qhcthanh on 7/28/16.
//  Copyright © 2016 VNG Corp. All rights reserved.
//

#import "AuthenticationViewController.h"
#import <GoogleSignIn/GoogleSignIn.h>
#import "YLRequestManager.h"
#import "YLExtDefines.h"
#import "YLPerson.h"
#import "AuthenticatedNavigationController.h"
#import "MBProgressHUD.h"
#import "YLTabbarViewController.h"


@import Firebase;

#define kWidthSignGoogleButton 312
#define kHeightSignGoogleButton 45

@interface AuthenticationViewController () <GIDSignInUIDelegate, GIDSignInDelegate>

@property GIDSignInButton *signGoogleButton;
@property FIRDatabaseReference *rootRef;
@property (nonatomic, strong) MBProgressHUD *hudLoadingView;

@end

@implementation AuthenticationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    // Start observe user login
    [YLUserInfo sharedUserInfo];
    [YLRequestManager sharedRequestManager];
    
    // Setup Google Sign Button
    [GIDSignIn sharedInstance].uiDelegate = self;
    [GIDSignIn sharedInstance].delegate = self;
    
    // Inititalize sign Google button
    _signGoogleButton = [[GIDSignInButton alloc] initWithFrame:CGRectMake(CGRectGetMidX(self.view.frame) - kWidthSignGoogleButton/2, CGRectGetMidY(self.view.frame) - kHeightSignGoogleButton/2, kWidthSignGoogleButton, kHeightSignGoogleButton)];
    
    _signGoogleButton.style = kGIDSignInButtonStyleWide;
    
    // addSubView
    [self.view addSubview:_signGoogleButton];
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificateUserModeUpdated) name:kNotificationUserModelUpdated object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificateLoadingModel) name:kNotificationLoadingData object:nil];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    // Remove observer Authentication
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)dealloc {
    // Remove obsever
    [_rootRef removeAllObservers];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Receive Notification

- (void)notificateUserModeUpdated {
    
    // Hide hud
    if (_hudLoadingView) {
        [_hudLoadingView hideAnimated:true];
        _hudLoadingView = nil;
    }
    
    // Have user sign in and load data success
    id tabbarVC = [self.storyboard instantiateViewControllerWithIdentifier:NSStringFromClass([YLTabbarViewController class])];
    
    [self presentViewController:tabbarVC animated:YES completion:nil];
}

- (void)notificateLoadingModel {
    // Settup hub
    if ( !_hudLoadingView) {
        _hudLoadingView = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        _hudLoadingView.mode = MBProgressHUDModeIndeterminate;
        _hudLoadingView.label.text = @"Loading";
    }
}

#pragma mark - GIDSignInDelegate

- (void)signIn:(GIDSignIn *)signIn didSignInForUser:(GIDGoogleUser *)user withError:(NSError *)error {
    if (error == nil) {
        // Get credential to sign in with Firebase
        GIDAuthentication *authentication = user.authentication;
        FIRAuthCredential *credential = [FIRGoogleAuthProvider credentialWithIDToken:authentication.idToken
                                         accessToken:authentication.accessToken];
        
        // Sign Firebase with Crendential
        [[FIRAuth auth] signInWithCredential:credential
                                  completion:^(FIRUser *user, NSError *error) {
                                      
                                  }];
    }
}

@end
