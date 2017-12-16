//
//  YLSQLCommand.m
//  SQLiteSummary
//
//  Created by VanDao on 8/2/16.
//  Copyright © 2016 VanDao. All rights reserved.
//

#import "YLSQLCommand.h"
#import "NSString+SQLExtension.h"

@interface YLSQLCommand ()

@end

@implementation YLSQLCommand

- (instancetype)initWithString:(NSString *)sql {
    
    self = [super init];
    
    if (self) {
        _sqlCommand = sql;
    }
    
    return self;
}

- (instancetype)initWithFormat:(NSString *)format, ... {
    
    self = [super init];
    
    if (self) {
        
        va_list args;
        va_start(args, format);
        
        _sqlCommand = [[NSString alloc]initWithFormat:format arguments:args];
        
        va_end(args);
    }
    
    return self;
}

- (instancetype)initWithCommand:(NSString *)command withParametersInDictionary:(NSDictionary *)parameters {
    
    self = [super init];
    
    if (self) {
        _sqlCommand = [NSString stringWithFormat:command withParametersInDictionnary:parameters];
    }
    
    return self;
}

- (instancetype)initWithCommand:(NSString *)command withParametersInArray:(NSArray *)parameters {
    
    self = [super init];
    
    if (self) {
        _sqlCommand = [NSString stringWithFormat:command withParametersInArray:parameters];
    }
    
    return self;
}

+ (instancetype)SQLCommandWithFormat:(NSString *)format, ... {
    
    va_list args;
    va_start(args, format);
    NSString *sqlCommand = [[NSString alloc]initWithFormat:format arguments:args];
    va_end(args);
    
    return [[self alloc]initWithString:sqlCommand];
}

+ (instancetype)SQLCommand:(NSString *)command withParametersInDictionnary:(NSDictionary *)parameters {
    
    return [[self alloc]initWithCommand:command withParametersInDictionary:parameters];
}

+ (instancetype)SQLCommand:(NSString *)command withParametersInArray:(NSArray<NSString *> *)parameters {
    
    return [[self alloc]initWithCommand:command withParametersInArray:parameters];
}

@end

#pragma YLSQLCommand + SQLiteStatement

@implementation YLSQLCommand (SQLiteStatement)

- (sqlite3_stmt *)createSQLStatementFromDatabase:(sqlite3 *)database {

    sqlite3_stmt *pStmt = NULL;
    
    int msgReceive = sqlite3_prepare_v2(database, [_sqlCommand UTF8String], -1, &pStmt, 0);
    
    return (msgReceive == SQLITE_OK) ? pStmt : NULL;
}


- (void)bindObject:(id)object toColumn:(int)columnIndex inStatement:(sqlite3_stmt *)statement{

    if ((!object) || ((NSNull *)object == [NSNull null])) {
        sqlite3_bind_null(statement, columnIndex);
    }

    // FIXME - someday check the return codes on these binds.
    else if ([object isKindOfClass:[NSData class]]) {
        const void *bytes = [object bytes];
        if (!bytes) {
            // it's an empty NSData object, aka [NSData data].
            // Don't pass a NULL pointer, or sqlite will bind a SQL null instead of a blob.
            bytes = "";
        }
        sqlite3_bind_blob(statement, columnIndex, bytes, (int)[object length], SQLITE_STATIC);
    }
    else if ([object isKindOfClass:[NSDate class]]) {
        //  if (YES)
        //      sqlite3_bind_text(_statement, columnIndex, [[[[NSDateFormatter alloc]init] stringFromDate:object] UTF8String], -1, SQLITE_STATIC);
        //   else
        sqlite3_bind_double(statement, columnIndex, [object timeIntervalSince1970]);
    }
    else if ([object isKindOfClass:[NSNumber class]]) {

        if (strcmp([object objCType], @encode(char)) == 0) {
            sqlite3_bind_int(statement, columnIndex, [object charValue]);
        }
        else if (strcmp([object objCType], @encode(unsigned char)) == 0) {
            sqlite3_bind_int(statement, columnIndex, [object unsignedCharValue]);
        }
        else if (strcmp([object objCType], @encode(short)) == 0) {
            sqlite3_bind_int(statement, columnIndex, [object shortValue]);
        }
        else if (strcmp([object objCType], @encode(unsigned short)) == 0) {
            sqlite3_bind_int(statement, columnIndex, [object unsignedShortValue]);
        }
        else if (strcmp([object objCType], @encode(int)) == 0) {
            sqlite3_bind_int(statement, columnIndex, [object intValue]);
        }
        else if (strcmp([object objCType], @encode(unsigned int)) == 0) {
            sqlite3_bind_int64(statement, columnIndex, (long long)[object unsignedIntValue]);
        }
        else if (strcmp([object objCType], @encode(long)) == 0) {
            sqlite3_bind_int64(statement, columnIndex, [object longValue]);
        }
        else if (strcmp([object objCType], @encode(unsigned long)) == 0) {
            sqlite3_bind_int64(statement, columnIndex, (long long)[object unsignedLongValue]);
        }
        else if (strcmp([object objCType], @encode(long long)) == 0) {
            sqlite3_bind_int64(statement, columnIndex, [object longLongValue]);
        }
        else if (strcmp([object objCType], @encode(unsigned long long)) == 0) {
            sqlite3_bind_int64(statement, columnIndex, (long long)[object unsignedLongLongValue]);
        }
        else if (strcmp([object objCType], @encode(float)) == 0) {
            sqlite3_bind_double(statement, columnIndex, [object floatValue]);
        }
        else if (strcmp([object objCType], @encode(double)) == 0) {
         //   sqlite3_bind_double(statement, columnIndex, [object doubleValue]);
        }
        else if (strcmp([object objCType], @encode(BOOL)) == 0) {
            sqlite3_bind_int(statement, columnIndex, ([object boolValue] ? 1 : 0));
        }
        else {
            sqlite3_bind_text(statement, columnIndex, [[object description] UTF8String], -1, SQLITE_STATIC);
        }
    }
    else {
        sqlite3_bind_text(statement, columnIndex, [[object description] UTF8String], -1, SQLITE_STATIC);
    }
}

@end
