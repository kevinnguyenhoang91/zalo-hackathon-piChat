//
//  YLSQLDatabase.h
//  SQLiteSummary
//
//  Created by VanDao on 8/1/16.
//  Copyright © 2016 VanDao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YLSQLCommand.h"
#import "YLSQLResult.h"

/**
 *  Define options to open database
 */
typedef NS_ENUM(NSUInteger, DatabaseOpenOption) {
    /**
     *  Readonly
     */
    kDatabaseOpenOptionReadonly = SQLITE_OPEN_READONLY,
    /**
     *  Read and write if possible
     */
    kDatabaseOpenOptionReadwrite = SQLITE_OPEN_READWRITE,
    /**
     *  Read and write if possible, and create new database if the path does not exist
     */
    kDatabaseOpenOptionCreateReadwrite = SQLITE_OPEN_READWRITE | SQLITE_OPEN_CREATE,
};

/**
 *  Callback block is called after executed query statment.
 *
 *  @param error  The error if the query was execute fail, otherwise, error is nil value.
 *  @param result The list of row from query statement if executed successfully.
 */
typedef void(^ExecuteCommandCallbackBlock)(NSError *error, YLSQLResult *result);

@interface YLSQLDatabase : NSObject

@property (readonly, strong) NSString *databasePath;
@property (readonly) sqlite3 *database;

/**
 *  Creates and returns an `YLSQLDatabase` object with specified DB path
 *
 *  @param path The path of the database
 *
 *  @return The newly `YLSQLDatabase` object
 */
+ (instancetype)databaseWithPath:(NSString *)path;

/**
 *  Initializes an `YLSQLDatabase` object with specified DB path
 *
 *  @param path The path of the database
 *
 *  @return The newly-initialized `YLSQLDatabase` object
 */
- (instancetype)initWithPath:(NSString *)path;

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
- (BOOL)openDatabaseWithOption:(DatabaseOpenOption)option;

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
- (BOOL)closeDatabase;

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
 *  @param command The command to be executed.
 *
 *  @return The YLSQLResult.
 */
- (YLSQLResult *)executeQueryCommand:(YLSQLCommand *)command;

/**
 *  Executed single command statement
 *
 *  @param sql           The command to be executed
 *  @param callbackBlock The block that will be called when command executed successfully.
 *  @param callbackQueue The queue that block will be executed.
 */
- (void)executeQueryCommand:(YLSQLCommand *)sqlCommand withCompletionHandler:(ExecuteCommandCallbackBlock)callbackBlock onQueue:(dispatch_queue_t)callbackQueue;

/**
 *  Execute single command statement, if you don't have data result for sql command, you should use this method
 *
 *  @param sqlCommand The command to be executed
 *
 *  @return YES if the command executed successfully, otherwise, return NO
 */
- (BOOL)executeCommand:(YLSQLCommand *)sqlCommand;

/**
 *  Executed single command statement
 *
 *  @param sql           The command to be executed
 *  @param callbackBlock The block that will be called when command executed successfully.
 *  @param callbackQueue The queue that block will be executed.
 */
- (void)executeCommand:(YLSQLCommand *)sqlCommand withCompletionHandler:(ExecuteCommandCallbackBlock)callbackBlock onQueue:(dispatch_queue_t)callbackQueue;

/**
 *  Begin transaction
 *
 *  @return YES if begin successfully, otherwise, NO
 */
- (BOOL)beginTransaction;

/**
 *  Commit transaction
 *
 *  @return YES if commit successfully, otherwise, NO
 */
- (BOOL)commitTransaction;

/**
 *  Rollback transaction
 *
 *  @return YES if rollback successfully, otherwise, NO
 */
- (BOOL)rollbackTransaction;

/**
 *  Excecute multilple commands in transaction block, if any command if run failed, all commands in transaction will be ignore.
 *
 *  @param transactionBlock The block to execute commands, if you want to commit, return YES in block, if you want to rollback return NO
 *
 *  @return YES if transaction execute successfully, otherwise, return NO
 */
- (BOOL)executeInTransaction:(BOOL(^)())transactionBlock;

@end