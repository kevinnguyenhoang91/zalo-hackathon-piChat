//
//  YLSQLResultCursor.m
//  YALO
//
//  Created by Nguyen Van Dao on 8/3/16.
//  Copyright © 2016 admin. All rights reserved.
//

#import "YLSQLResultCursor.h"
#import "int_type.h"
#include <libkern/OSAtomic.h>

@interface YLSQLResultCursor ()

@property sqlite3_stmt *statement;
@property NSMutableArray<NSDictionary *> *currentResult;
@property NSMutableDictionary *currentRowData;
@property dispatch_queue_t internalSerialQueue;

@property (atomic) NSInteger currentRowIndex;

@end

@implementation YLSQLResultCursor

- (instancetype)init {
    
    self = [super init];
    
    if (self) {
        _listOfColumnAttributes = [[NSMutableArray alloc]init];
        _currentResult = [[NSMutableArray alloc]init];
        _currentRowData = nil;
        _currentRowIndex = 0;
        _internalSerialQueue = dispatch_queue_create("com.YALO.YLSQLResultCursor.internalSerialQueue", DISPATCH_QUEUE_SERIAL);
    }
    
    return self;
}

+ (instancetype)resultCursorWithSQLCommand:(YLSQLCommand *)sqlCommand inDatabase:(YLSQLDatabase *)database {
    return [[self alloc]initWithSQLCommand:sqlCommand inDatabase:database];
}

- (instancetype)initWithSQLCommand:(YLSQLCommand *)sqlCommand inDatabase:(YLSQLDatabase *)database {
    
    // Create new statement
    int msgReceive = sqlite3_prepare_v2(_database.database, [_sqlCommand.sqlCommand UTF8String], -1, &_statement, 0);
    
    if (msgReceive == SQLITE_OK) {
        // Statement create successfully
        self = [self init];
        
        if (self) {
            _sqlCommand = sqlCommand;
            _database = database;
            _statement = [sqlCommand createSQLStatementFromDatabase:_database.database];
            
            // Get column info
            NSUInteger num_cols = (NSUInteger)sqlite3_data_count(_statement);
            
            if (num_cols > 0) {

                
                // Count number of column
                int columnCount = sqlite3_column_count(_statement);
                
                // Get column attributes for each column in statement
                for (int columnIdx = 0; columnIdx < columnCount; columnIdx++) {
                    

                    YLSQLColumnAttributes *columnAttributes = [[YLSQLColumnAttributes alloc]init];
                    
                    columnAttributes.cID = columnIdx;
                    columnAttributes.cName = [NSString stringWithUTF8String:sqlite3_column_name(_statement, columnIdx)];
                    NSString *columnType = [NSString stringWithUTF8String:sqlite3_column_decltype(_statement, columnIdx)];
                    columnAttributes.cType = [YLSQLDataTypeConverter dataTypeWithStringType:columnType];
                    
                    [_listOfColumnAttributes addObject:columnAttributes];
                }
            }
        }
        
        return self;
    }
    else {
        
        // Failed to create statement
        return nil;
    }
}

- (BOOL)jumpToNextRow {
    
    __block BOOL res = YES;
    
    dispatch_sync(_internalSerialQueue, ^{
        int msgReceive = sqlite3_step(_statement);
        
        if (msgReceive == SQLITE_ROW) {
            
            _currentRowIndex++;
            _currentRowData = nil;
        } else
            res = NO;
    });
    
    return res;
}

- (NSDictionary *)getCurrentRowResult {
    
    if (!_currentRowData) {
        
        NSUInteger numColumn = (NSUInteger)sqlite3_data_count(_statement);
        
        if (numColumn > 0) {
            _currentRowData = [NSMutableDictionary dictionary];
            
            int columnCount = sqlite3_column_count(_statement);
            
            for (int index = 0; index < columnCount; index++) {
                
                NSString *columnName = [NSString stringWithUTF8String:sqlite3_column_name(_statement, index)];
                [_currentRowData setObject:[self objectForColumnIndex:index] forKey:columnName];
            }
        }
    }
    
    return _currentRowData;
}

- (NSArray<NSDictionary *> *)getAllResultAndJumpCursorToEndRow {
    
    if (!_currentRowData)
        [self getCurrentRowResult];
    
    while ([self jumpToNextRow]) {
        [self getCurrentRowResult];
    }
    
    return _currentResult;
}

- (YLSQLDataValue *)objectForColumnIndex:(int)columnIndex {

    const char* rawData = (const char*)sqlite3_column_text(_statement, columnIndex);
    return [YLSQLDataValue valueWithRawValue: rawData ? [NSString stringWithUTF8String:rawData] : nil];
}

- (void)clean {
    
    dispatch_async(_internalSerialQueue, ^{
        sqlite3_reset(_statement);
        _currentRowData = nil;
        _currentResult = [[NSMutableArray alloc]init];
    });
}

- (void)dealloc {
    
    sqlite3_finalize(_statement);
}

@end
