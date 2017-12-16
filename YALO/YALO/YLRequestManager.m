//
//  YLRequestManager.m
//  YALO
//
//  Created by BaoNQ on 7/29/16.
//  Copyright © 2016 admin. All rights reserved.
//

#import "YLRequestManager.h"
#import "YLPerson.h"
#import "YLExtDefines.h"
#import "YLDatabaseManager.h"

@interface YLRequestManager ()

@property FIRDatabaseReference* rootRef;
@property FIRAuthStateDidChangeListenerHandle authStateDidChangeListenerHandle;

@end

@implementation YLRequestManager

+ (instancetype)sharedRequestManager {
    
    static YLRequestManager *sharedManager = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        sharedManager = [[self alloc] init];

    });
    return sharedManager;
}

- (id)init {
    self = [super init];
    
    if (!self)
        return nil;
    
    _rootRef = [[[FIRDatabase database] reference] child:kRootKey];
    _authStateDidChangeListenerHandle = [self addAuthStateDidChangeListener];
    
    return self;
}

- (FIRAuthStateDidChangeListenerHandle)addAuthStateDidChangeListener {
    
    FIRAuthStateDidChangeListenerHandle authStateDidChangeListener = [[FIRAuth auth] addAuthStateDidChangeListener:^(FIRAuth *_Nonnull auth, FIRUser *_Nullable user) {
        
        if (user != nil) {
            // NOTIFICATION USER LOAD HUB
            [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationLoadingData object:nil];
            
            // User is signed in.
            for (id<FIRUserInfo> profile in user.providerData) {
                FIRDatabaseReference *userRef = [[_rootRef child:kUsersKey] child:user.uid];
                
                [userRef observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
                    
                    NSDictionary* data;
                    if (!snapshot.exists) {
                        data = @{ YLPersonInfoUserIDKey:        user.uid,
                                  YLPersonInfoUserNameKey:      profile.displayName,
                                  YLPersonInfoAvatarURLKey:     profile.photoURL ? profile.photoURL.absoluteString : @"",
                                  YLPersonInfoEmailKey:         profile.email,
                                  YLPersonInfoLastLogonTimeKey: [NSNumber numberWithDouble:[[NSDate date] timeIntervalSince1970]],
                                  };
                        [self insertChild:user.uid withData:data toPath:kUsersKey];
                    }
                    else {
                        NSNumber *lastLogonTime = [NSNumber numberWithDouble:[[NSDate date] timeIntervalSince1970]];
                        [[userRef child:YLPersonInfoLastLogonTimeKey] setValue:lastLogonTime];
                        
                        NSMutableDictionary* userData = snapshot.value;
                        [userData setValue:lastLogonTime forKey:YLPersonInfoLastLogonTimeKey];
                        data = userData;
                    }
                    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationUserLoggedIn object:nil userInfo:data];
                }];
                
            }
         // Load local database
            [[YLUserInfo sharedUserInfo] loadUserInfoLocal];
            
            // 1 notification # (da load data tu local)
          //    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationUserLoggedIn object:nil userInfo:data];
        } else {
            
        }
        
    }];
    return authStateDidChangeListener;
}

- (void)selectDataFromPath:(NSString *)path completionBlock:(void (^)(NSDictionary *data))completionBlock {
    [self selectDataFromPath:path completionBlock:completionBlock cancelBlock:nil];
}

- (void)selectDataFromPath:(NSString *)path completionBlock:(void (^)(NSDictionary *data))completionBlock cancelBlock:(void (^)(NSError *error))cancelBlock {
    FIRDatabaseReference *dbRef = [_rootRef child:path];
    
    [dbRef observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        if (completionBlock) {
            completionBlock(snapshot.value);
        }
    } withCancelBlock:^(NSError *error) {
        if (cancelBlock)
            cancelBlock(error);
    }];
}

- (void)insertChild:(NSString *)child withData:(nullable id)data toPath:(NSString *)path {

    FIRDatabaseReference *dbRef = [_rootRef child:path];
    dbRef = [dbRef child:child];
    
    [dbRef setValue:data];
}

- (void)insertChild:(NSString *)child withData:(id)data toPath:(NSString *)path withCompletion:(void(^)(NSError * _Nullable error))completion {
    
    FIRDatabaseReference *dbRef = [_rootRef child:path];
    dbRef = [dbRef child:child];
    
    [dbRef setValue:data withCompletionBlock:^(NSError * _Nullable error, FIRDatabaseReference * _Nonnull ref) {
        completion(error);
    }];
}

- (NSString *)insertChildByAutoIDwithData:(id)data toPath:(NSString *)path {
    
    FIRDatabaseReference *dbRef = [_rootRef child:path];
    dbRef = [dbRef childByAutoId];
    
    [dbRef setValue:data];
    
    return dbRef.key;
}

- (NSString *)getAutoIDWithPath:(NSString *)path {
    
    FIRDatabaseReference *dbRef = [_rootRef child:path];
    dbRef = [dbRef childByAutoId];
    
    return dbRef.key;
}

- (YLDatabaseHandle)observeDataFromPath:(NSString *)path withEventType:(YLDataEventType)eventType completionBlock:(void (^)(NSDictionary *data))completionBlock {
   
    FIRDatabaseReference *dbRef = [_rootRef child:path];
    FIRDataEventType eventTypeFIR = (FIRDataEventType)eventType;

    YLDatabaseHandle dbHandle = [dbRef observeEventType:eventTypeFIR withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        if (completionBlock) {
            NSDictionary* data = @{snapshot.key:snapshot.value };
            completionBlock(data);
        }
    }];
    
    return dbHandle;
}

- (void)removeObserveWithHandle:(YLDatabaseHandle)handle {
    [_rootRef removeObserverWithHandle:handle];
}

- (void)setValueAtPath:(NSString *)path withData:(id)data {
    FIRDatabaseReference *dbRef = [_rootRef child:path];
    
    [dbRef setValue:data];
}

@end
