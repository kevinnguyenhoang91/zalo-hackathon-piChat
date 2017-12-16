////
////  YLSQLite.m
////  YALO
////
////  Created by qhcthanh on 7/29/16.
////  Copyright © 2016 admin. All rights reserved.
////
//
//#import "YLSQLite.h"
//
//@interface YLSQLite ()
//
//@property void* db;
//@property NSString* databasePath;
//@property BOOL isExecutingStatement;
//@property NSMutableDictionary *_cachedStatements;
//@property NSMutableSet *_openResultSets;
//@property NSMutableSet *_openFunctions;
//
//@end
//
//@implementation YLSQLite
//
//- (instancetype)initWithPath:(NSString*)aPath {
//    
//    assert(sqlite3_threadsafe()); // whoa there big boy- gotta make sure sqlite it happy with what we're going to do.
//    
//    self = [super init];
//    
//    if (self) {
//        _databasePath               = [aPath copy];
//        _openResultSets             = [[NSMutableSet alloc] init];
//        _db                         = nil;
//    }
//    
//    return self;
//}
//
//- (void)finalize {
//    [self close];
//    [super finalize];
//}
//
//- (void)dealloc {
//    [self close];
//}
//
//- (NSString *)databasePath {
//    return _databasePath;
//}
//
//+ (BOOL)isSQLiteThreadSafe {
//    // make sure to read the sqlite headers on this guy!
//    return sqlite3_threadsafe() != 0;
//}
//
//- (void*)sqliteHandle {
//    return _db;
//}
//
//#pragma mark Open and close database
//
//- (BOOL)open {
//    if (_db) {
//        return YES;
//    }
//    
//    int err = sqlite3_open([self sqlitePath], (sqlite3**)&_db );
//    if(err != SQLITE_OK) {
//        NSLog(@"error opening!: %d", err);
//        return NO;
//    }
//    
//    if (_maxBusyRetryTimeInterval > 0.0) {
//        // set the handler
//        [self setMaxBusyRetryTimeInterval:_maxBusyRetryTimeInterval];
//    }
//    
//    
//    return YES;
//}
//
//- (BOOL)close {
//    
//    [self closeOpenResultSets];
//    
//    if (!_db) {
//        return YES;
//    }
//    
//    int  rc;
//    BOOL retry;
//    BOOL triedFinalizingOpenStatements = NO;
//    
//    do {
//        retry = NO;
//        rc = sqlite3_close(_db);
//        if (SQLITE_BUSY == rc || SQLITE_LOCKED == rc) {
//            if (!triedFinalizingOpenStatements) {
//                triedFinalizingOpenStatements = YES;
//                
//                sqlite3_stmt *pStmt;
//                while ((pStmt = sqlite3_next_stmt(_db, nil)) != 0) {
//                    sqlite3_finalize(pStmt);
//                    retry = YES;
//                }
//            }
//        }
//        else if (SQLITE_OK != rc) {
//            NSLog(@"error closing!: %d", rc);
//        }
//    }
//    while (retry);
//    
//    _db = nil;
//    return YES;
//}
//
//#pragma mark Result set functions
//
//- (BOOL)hasOpenResultSets {
//    return [_openResultSets count] > 0;
//}
//
//- (void)closeOpenResultSets {
//    
//    //Copy the set so we don't get mutation errors
//    NSSet *openSetCopy = FMDBReturnAutoreleased([_openResultSets copy]);
//    for (NSValue *rsInWrappedInATastyValueMeal in openSetCopy) {
//        FMResultSet *rs = (FMResultSet *)[rsInWrappedInATastyValueMeal pointerValue];
//        
//        [rs setParentDB:nil];
//        [rs close];
//        
//        [_openResultSets removeObject:rsInWrappedInATastyValueMeal];
//    }
//}
//
//#pragma mark State of database
//
//- (void)resultSetDidClose:(FMResultSet *)resultSet {
//    NSValue *setValue = [NSValue valueWithNonretainedObject:resultSet];
//    
//    [_openResultSets removeObject:setValue];
//}
//
//- (BOOL)databaseExists {
//    
//    if (!_db) {
//        
//        NSLog(@"The FMDatabase %@ is not open.", self);
//        
//#ifndef NS_BLOCK_ASSERTIONS
//        if (_crashOnErrors) {
//            NSAssert(false, @"The FMDatabase %@ is not open.", self);
//            abort();
//        }
//#endif
//        
//        return NO;
//    }
//    
//    return YES;
//}
//
//
//#pragma mark Execute updates
//- (BOOL)executeStatements:(NSString *)sql {
//    return [self executeStatements:sql withResultBlock:nil];
//}
//
//- (BOOL)executeStatements:(NSString *)sql withResultBlock:(FMDBExecuteStatementsCallbackBlock)block {
//    
//    int rc;
//    char *errmsg = nil;
//    
//    rc = sqlite3_exec([self sqliteHandle], [sql UTF8String], block ? FMDBExecuteBulkSQLCallback : nil, (__bridge void *)(block), &errmsg);
//    
//    if (errmsg && [self logsErrors]) {
//        NSLog(@"Error inserting batch: %s", errmsg);
//        sqlite3_free(errmsg);
//    }
//    
//    return (rc == SQLITE_OK);
//}
//
//
//@end
