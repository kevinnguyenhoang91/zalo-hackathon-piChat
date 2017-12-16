//
//  YLRequestManager.h
//  YALO
//
//  Created by BaoNQ on 7/29/16.
//  Copyright © 2016 admin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GoogleSignIn/GoogleSignIn.h>
@import Firebase;

typedef NS_ENUM(NSInteger, YLDataEventType) {
    YLDataEventTypeChildAdded = FIRDataEventTypeChildAdded,    // 0, fired when a new child node is added to a location
    YLDataEventTypeChildRemoved,  // 1, fired when a child node is removed from a location
    YLDataEventTypeChildChanged,  // 2, fired when a child node at a location changes
    YLDataEventTypeChildMoved,    // 3, fired when a child node moves relative to the other child nodes at a location
    YLDataEventTypeValue          // 4, fired when any data changes at a location and, recursively, any children
};

typedef NSUInteger YLDatabaseHandle;


//    When you init the YLRequestManager for the first time, a block as a "AuthStateDidChangeListener" will be registered.
//    To be invoked when:
//        - The block is registered as a listener,
//        - The current user changes, or, the current user's access token changes.
//    Remarks:    The block is invoked immediately after adding it according to it's standard invocation semantics, asynchronously on the	 main thread.
//                Users should pay special attention to making sure the block does not inadvertently retain objects which should not be retained by the long-lived block.
//                The block itself will be retained by FIRAuth until it is unregistered or until the FIRAuth instance is otherwise deallocated.
@interface YLRequestManager : NSObject

/**
 *  Singletion method of request manager.
 */
+ (instancetype)sharedRequestManager;

/**
 *  Read data from Firebase Database at a particular location. 
    The location is specified by a path which does not contain the Root key.
 *
 *  @param path             The specified path in Firebase tree.
 *  @param completionBlock  The block that should be called with initial data. It is passed the data as a NSDictionary.
                            The key for each value is identified by key value in Firebase tree.
 */
- (void)selectDataFromPath:(NSString *)path completionBlock:(void (^)(NSDictionary *data))completionBlock;

/**
 *  Read data from Firebase Database at a particular location.
    The location is specified by a path which does not contain the Root key.
    
    The cancelBlock will be called if you do not have permission to read data at this location.
 *
 *  @param path             The specified path in Firebase tree.
 *  @param completionBlock  The block that should be called with initial data. It is passed the data as a NSDictionary.
                            The key for each value is identified by key value in Firebase tree.
 *  @param cancelBlock      The block will be called if you do not have permission to read data at this location.
 */
- (void)selectDataFromPath:(NSString *)path completionBlock:(void (^)(NSDictionary *data))completionBlock cancelBlock:(void (^)(NSError *error))cancelBlock;

/**
 *  Write data to this Firebase Database location. The location is specified by a path which does not contain the Root key.

    This will overwrite any data at this location and all child locations.
    Passing null for the new value is equivalent to calling remove:;all data at this location or any child location will be deleted.
 *
 *  @param child    The new child location in the 'path'.
 *  @param data     Data to be written.
 *  @param path     The specified path in Firebase tree.
 */
- (void)insertChild:(NSString *)child withData:(id)data toPath:(NSString *)path;

/**
 *  Write data to this Firebase Database location. The location is specified by a path which does not contain the Root key.
    Generates a new child location using a unique key. This is useful when the children of a Firebase Database location represent a list of items.
    The unique key is prefixed with a client-generated timestamp so that the resulting list will be chronologically-sorted.

    This will overwrite any data at this location and all child locations.
    Passing null for the new value is equivalent to calling remove:;all data at this location or any child location will be deleted.
 *
 *  @param data     Data to be written.
 *  @param path     The specified path in Firebase tree.
 */
- (NSString *)insertChildByAutoIDwithData:(id)data toPath:(NSString *)path;

/**
 *  Write data to this Firebase Database location. The location is specified by a path which does not contain the Root key.
 *
 *  @param child      This child will be added to Firebase tree.
 *  @param data       Data to be written
 *  @param path       The specified path in Firebase tree.
 *  @param completion The block to be called after the write has been committed to the Firebase servers.
 */
- (void)insertChild:(NSString *)child withData:(id)data toPath:(NSString *)path withCompletion:(void(^)(NSError *error))completion;

/**
 *  Generates a new child location using a unique key in a specified path
 *
 *  @param path The specified path in Firebase tree.
 *
 *  @return The auto ID child.
 */
- (NSString *)getAutoIDWithPath:(NSString *)path;

/**
 *  Used to listen for data changes at a particular location. This is the primary way to read data from the Firebase Database. 
    Your block will be triggered for the initial data and again whenever the data changes.
 Use removeObserverWithHandle: to stop receiving updates.
 *
 *  @param path            The path of Firebase tree to listen for.
 *  @param eventType       The type of event to listen for.
 *  @param completionBlock The block that should be called with initial data and updates. It is passed the data as a NSDictionary.
 *
 *  @return A handle used to unregister this block later using removeObserverWithHandle:
 */
- (YLDatabaseHandle)observeDataFromPath:(NSString *)path withEventType:(YLDataEventType)eventType completionBlock:(void (^)(NSDictionary *data))completionBlock;

/**
 *  Detach a block previously attached
 *
 *  @param handle The handle returned by the call to observeDataFromPath:withEventType:completionBlock: which we are trying to remove.
 */
- (void)removeObserveWithHandle:(YLDatabaseHandle)handle;

/**
 *  Write data to this Firebase Database location.
    This will overwrite any data at this location and all child locations.
    The effect of the write will be visible immediately and the correspondingevents will be triggered. Synchronization of the data to the Firebase Databaseservers will also be started.
    Passing data with 'null' for the new value is equivalent to calling remove:;all data at this location or any child location will be deleted.
 *
 *  @param path Data will be added to this path immediately.
 *  @param data Data to be written.
 */
- (void)setValueAtPath:(NSString *)path withData:(id)data;


@end
