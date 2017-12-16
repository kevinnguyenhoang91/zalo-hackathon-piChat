//
//  YLDatabaseQueue.h
//  YALO
//
//  Created by VanDao on 8/12/16.
//  Copyright © 2016 admin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YLExpression.h"
#import "YLSortDescription.h"
#import "YLSQLDatabase.h"
#import "YLBaseModel.h"

typedef void(^ExecutedCallbackBlock)(NSError *error, YLSQLResult *result);

@interface YLDatabaseQueue : NSObject

@property(readonly) YLSQLDatabase *dbConnection;
@property(readonly) NSOperationQueue *operationQueue;
@property(assign, readonly) dispatch_queue_t underlyingQueue;

/**
 *  Creates and return `YLDatabaseQueue` object with specifier database path
 *
 *  @param databasePath The path of database
 *
 *  @return The newly-`YLDatabaseQueue` object
 */
+ (instancetype)databaseWithPath:(NSString *)databasePath;

/**
 *  Create and return `YLDatabaseQueue` object with specifier database path and executing queue
 *
 *  @param databasePath The path of database
 *  @param queue        The underlying queue that the operation queue used to execute
 *
 *  @return The newly-`YLDatabaseQueue` object
 */
+ (instancetype)databaseWithPath:(NSString *)databasePath underlyingQueue:(dispatch_queue_t)queue;

/**
 *  Opening a new database connection with specified optional.
 *  @param option The optional for opening database
 
 `kDatabaseOpenOptionReadonly`
 The database is opened in read-only mode.
 
 `kDatabaseOpenOptionReadwrite`
 The database is opened for reading and writting if possible.
 
 `kDatabaseOpenOptionCreateReadWrite`
 The database is opened for reading and writting, and created new database if it does not exist.
 *
 */
- (void)openDatabaseWithOption:(DatabaseOpenOption)option;

/**
 *  Opening a new database connection with specified optional.
 *
 *  @param option The optional for opening database
 
 `kDatabaseOpenOptionReadonly`
 The database is opened in read-only mode.
 
 `kDatabaseOpenOptionReadwrite`
 The database is opened for reading and writting if possible.
 
 `kDatabaseOpenOptionCreateReadWrite`
 The database is opened for reading and writting, and created new database if it does not exist.
 
 *  @param callbackBlock The block that will be called when open database finishes successfully.
 *  @param callBackQueue The queue that block will be executed.
 */
- (void)openDatabaseWithOption:(DatabaseOpenOption)option completionHandler:(void(^)(NSError *))callbackBlock onQueue:(dispatch_queue_t)callBackQueue;

/**
 *  Closing a database connection
 */
- (void)closeDatabase;

/**
 *  Closing a database connection with completion block hander
 *
 *  @param callbackBlock The block that will be called when close database finishes successfully
 *  @param callBackQueue The queue that block will be exectued
 */
- (void)closeDatabaseWithCompletionHandler:(void(^)(NSError *))callbackBlock onQueue:(dispatch_queue_t)callBackQueue;


/**
 *  Executed single command statement
 *
 *  @param sql           The command to be executed
 *  @param callbackBlock The block that will be called when command executed successfully.
 *  @param callbackQueue The queue that block will be executed.
 */
- (void)executeQueryCommand:(YLSQLCommand *)sqlCommand withPriority:(NSOperationQueuePriority)priority completionHandler:(ExecuteCommandCallbackBlock)callbackBlock onQueue:(dispatch_queue_t)callbackQueue;

/**
 *  Executed single command statement
 *
 *  @param sql           The command to be executed
 *  @param callbackBlock The block that will be called when command executed successfully.
 *  @param callbackQueue The queue that block will be executed.
 */
- (void)executeCommand:(YLSQLCommand *)sqlCommand withPriority:(NSOperationQueuePriority)priority completionHandler:(ExecuteCommandCallbackBlock)callbackBlock onQueue:(dispatch_queue_t)callbackQueue;

/**
 *  Begin transaction
 */
- (void)beginTransactionWithPriority:(NSOperationQueuePriority)priority;

/**
 *  Commit transaction to update all changes
 */
- (void)commitTransactionWithPriority:(NSOperationQueuePriority)priority;

/**
 *  Rollback to begin point, all changes will dismiss
 */
- (void)rollbackTransactionWithPriority:(NSOperationQueuePriority)priority;

/**
 *  Excecute multilple commands in transaction block, if any command if run failed, all commands in transaction will be ignore.
 *
 *  @param transactionBlock The block to execute commands, you must to return
 *  @param callbackBlock    The block that will be called when transaction executed successfully
 *  @param callbackQueue    The queue that block will be executed
 */
- (void)executeInTransaction:(NSArray *)commandList withPriority:(NSOperationQueuePriority)priority completionBlock:(void(^)(NSError *error))callbackBlock onQueue:(dispatch_queue_t)callbackQueue;

@end
