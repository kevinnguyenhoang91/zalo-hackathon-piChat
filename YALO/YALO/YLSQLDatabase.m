//
//  YLSQLDatabase.m
//  SQLiteSummary
//
//  Created by VanDao on 8/1/16.
//  Copyright © 2016 VanDao. All rights reserved.
//

#import "YLSQLDatabase.h"

#pragma YLSQLDatabase implementation

@interface YLSQLDatabase ()

@property dispatch_queue_t internalSerialQueue;
@property BOOL transactionFlag; // YES when openning transaction, otherwise, NO

@end

@implementation YLSQLDatabase

+ (instancetype)databaseWithPath:(NSString *)path {
    
    return [[self alloc] initWithPath:path];
}

- (instancetype)initWithPath:(NSString *)path {
    
    self = [super init];
    
    if (self) {
        _internalSerialQueue = dispatch_queue_create("com.YLDatabase.internalSerialQueue", DISPATCH_QUEUE_SERIAL);
        _databasePath = path;
        _database = nil;
        _transactionFlag = NO;
    }
    
    return self;
}

- (const char*)sqlitePath {
    
    return !_databasePath ? ":memory:" : ([_databasePath length] == 0) ? "" : [_databasePath fileSystemRepresentation];
}

- (BOOL)openDatabaseWithOption:(DatabaseOpenOption)option {
    
    __block BOOL res = false;
    
    dispatch_sync(_internalSerialQueue, ^{
        
        if (_database) {
            res = true;
        }
        else {
            int msgReceive = sqlite3_open_v2([self sqlitePath], (sqlite3**)&_database, option, nil);
            res = (msgReceive != SQLITE_OK) ? false : true;
        }
    });
    
    return res;
}

- (void)openDatabaseWithOption:(DatabaseOpenOption)option completionHandler:(void(^)(NSError *))callbackBlock onQueue:(dispatch_queue_t)callBackQueue {

    dispatch_async(_internalSerialQueue, ^{
        
        BOOL res = false;
        NSError *err = nil;
        
        if (_database) {
            res = true;
        }
        else {
            int msgReceive = sqlite3_open_v2([self sqlitePath], (sqlite3**)&_database, option, nil);
            if (msgReceive != SQLITE_OK) {
                res = false;
                err = [NSError errorWithDomain:@"com.YLDatabase.openDatabase" code:msgReceive userInfo:nil];
            }
        }
        
        if (callbackBlock) {
            dispatch_queue_t queue = callBackQueue ? callBackQueue : dispatch_get_main_queue();
            dispatch_async(queue, ^{
                callbackBlock(err);
            });
        }
    });
}

- (NSError *)tryToCloseDatabase {
    
    if (!_database)
        return [NSError errorWithDomain:@"com.YALO.closeDatabase" code:SQLITE_ERROR userInfo:nil];
    else {
        
        int msgReceive;
        BOOL retry;
        BOOL tryToFinalizingCurrentStatments = NO;
        
        do {
            
            retry = NO;
            msgReceive = sqlite3_close(_database);
            
            if (msgReceive == SQLITE_BUSY || msgReceive == SQLITE_LOCKED) {
                
                if (!tryToFinalizingCurrentStatments) {
                    
                    tryToFinalizingCurrentStatments = YES;
                    sqlite3_stmt *pStmt;
                    while ((pStmt = sqlite3_next_stmt(_database, nil)) != 0 ) {
                        sqlite3_finalize(pStmt);
                        retry = YES;
                    }
                }
            } else if (msgReceive != SQLITE_OK) {
                // Error closing
                return [NSError errorWithDomain:@"com.YALO.closeDatabase" code:msgReceive userInfo:nil];
            }
        } while (retry);
        
        _database = nil;
    }
    
    return nil;
}

- (BOOL)closeDatabase {
    
    __block BOOL res = false;
    
    dispatch_sync(_internalSerialQueue, ^{
        res = [self tryToCloseDatabase] ? true : false;
    });
    
    return res;
}

- (void)closeDatabaseWithCompletionHandler:(void(^)(NSError *))callbackBlock onQueue:(dispatch_queue_t)callBackQueue {

    dispatch_async(_internalSerialQueue, ^{
        
        NSError *err = [self tryToCloseDatabase];
        
        if (callbackBlock) {
            dispatch_queue_t queue = callBackQueue ? callBackQueue : dispatch_get_main_queue();
            dispatch_async(queue, ^{
                callbackBlock(err);
            });
        }
    });
}

int YLSQLExecuteCallbackFunction(void *resultArray, int columns, char **values, char **colNames) {
    
    if (!resultArray)
        return SQLITE_OK;
    
    NSMutableDictionary *rowData = [NSMutableDictionary dictionary];
    
    for(int i = 0; i < columns; i++) {
        NSString *rawValue = values[i] ? [NSString stringWithUTF8String:values[i]] : nil;
        YLSQLDataValue *dataValue = [YLSQLDataValue valueWithRawValue:rawValue];
        NSString *value = colNames[i] ? [NSString stringWithUTF8String: colNames[i]] : nil;
        [rowData setObject:dataValue forKey:value];
    }
    
    [(__bridge NSMutableArray *)resultArray addObject: rowData];
    
    return 0;
}

- (YLSQLResult *)executeQueryCommand:(YLSQLCommand *)command {
    
    __block YLSQLResult *result = nil;
    
    dispatch_sync(_internalSerialQueue, ^{
        int msgReceive;
        char *err = NULL;
        NSMutableArray *resultArray = [[NSMutableArray alloc]init];
        
        msgReceive = sqlite3_exec(_database, [command.sqlCommand UTF8String], YLSQLExecuteCallbackFunction, (__bridge void *)(resultArray), &err);
        
        if (msgReceive == SQLITE_OK)
            result = [YLSQLResult YLSQLResultWithArray:resultArray];
    });
    
    return result;
}

- (void)executeQueryCommand:(YLSQLCommand *)sqlCommand withCompletionHandler:(ExecuteCommandCallbackBlock)callbackBlock onQueue:(dispatch_queue_t)callbackQueue {
    
    dispatch_async(_internalSerialQueue, ^{
        
        YLSQLResult *result = nil;
        int msgReceive;
        char *err = NULL;
        NSError *error = nil;
        
        NSMutableArray *resultArray = [[NSMutableArray alloc]init];
        
        msgReceive = sqlite3_exec(_database, [sqlCommand.sqlCommand UTF8String], YLSQLExecuteCallbackFunction, (__bridge void *)(resultArray), &err);
        
        if (msgReceive == SQLITE_OK) {
            result = [YLSQLResult YLSQLResultWithArray:resultArray];
        }
        else {
            error = [NSError errorWithDomain:@"com.YALO.executeQueryCommand" code:msgReceive userInfo:nil];
        }
        
        if (callbackBlock) {
            dispatch_queue_t queue = callbackQueue ? callbackQueue : dispatch_get_main_queue();
            dispatch_async(queue, ^{
                callbackBlock(error, result);
            });
        }
    });
 }

- (BOOL)executeCommand:(YLSQLCommand *)sqlCommand {
    
    __block BOOL res = YES;
    
    dispatch_sync(_internalSerialQueue, ^{
        if (!_database)
            res = NO;
        
        int msgReceive;
        char *err = NULL;
        
        msgReceive = sqlite3_exec(_database, [sqlCommand.sqlCommand UTF8String], YLSQLExecuteCallbackFunction, 0, &err);
        
        if (msgReceive != SQLITE_OK) {
            res = NO;
            sqlite3_free(err);
        }
    });
    
    return res;
}

- (void)executeCommand:(YLSQLCommand *)sqlCommand withCompletionHandler:(ExecuteCommandCallbackBlock)callbackBlock onQueue:(dispatch_queue_t)callbackQueue {
    
    dispatch_async(_internalSerialQueue, ^{
        
        YLSQLResult *result = nil;
        int msgReceive;
        char *err = NULL;
        NSError *error = nil;
        
        msgReceive = sqlite3_exec(_database, [sqlCommand.sqlCommand UTF8String], 0, 0, &err);
        
        if (msgReceive != SQLITE_OK) {
            error = [NSError errorWithDomain:@"com.YALO.executeQueryCommand" code:msgReceive userInfo:nil];
        }
        
        if (callbackBlock) {
            dispatch_queue_t queue = callbackQueue ? callbackQueue : dispatch_get_main_queue();
            dispatch_async(queue, ^{
                callbackBlock(error, result);
            });
        }
    });
}


- (BOOL)beginTransaction {
    
    __block BOOL res = NO;
    
    dispatch_sync(_internalSerialQueue, ^{
        int msgReceive;
        
        // Begin transaction
        msgReceive = sqlite3_exec(_database, "BEGIN EXCLUSIVE TRANSACTION", 0, 0, 0);
        
        if (msgReceive == SQLITE_OK)
            res = YES;
    });
    
    return res;
}

- (BOOL)commitTransaction {
    
    __block BOOL res = NO;
    
    dispatch_sync(_internalSerialQueue, ^{
        int msgReceive;
        
        // Begin transaction
        msgReceive = sqlite3_exec(_database, "COMMIT TRANSACTION", 0, 0, 0);
        
        if (msgReceive == SQLITE_OK)
            res = YES;
    });
    
    return res;
}

- (BOOL)rollbackTransaction {
    
    __block BOOL res = NO;
    
    dispatch_sync(_internalSerialQueue, ^{
        int msgReceive;
        
        // Begin transaction
        msgReceive = sqlite3_exec(_database, "ROLLBACK TRANSACTION", 0, 0, 0);
        
        if (msgReceive == SQLITE_OK)
            res = YES;
    });
    
    return res;
}

- (BOOL)executeInTransaction:(BOOL(^)())transactionBlock {
    
    __block BOOL res = NO;
    
    dispatch_sync(_internalSerialQueue, ^{
        int msgReceive;
        
        // Begin transaction
        msgReceive = sqlite3_exec(_database, "BEGIN EXCLUSIVE TRANSACTION", 0, 0, 0);
        
        if (msgReceive) {
            int execSuccess = transactionBlock();
            
            if (execSuccess) {
                // Commit transaction
                msgReceive = sqlite3_exec(_database, "COMMIT TRANSACTION", 0, 0, 0);
            } else {
                // Rollback transaction
                msgReceive = sqlite3_exec(_database, "ROLLBACK TRANSACTION", 0, 0, 0);
            }
        }
        
        if (msgReceive == SQLITE_OK)
            res = YES;
    });
    
    return res;
}

@end

