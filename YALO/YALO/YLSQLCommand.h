//
//  YLSQLCommand.h
//  SQLiteSummary
//
//  Created by VanDao on 8/2/16.
//  Copyright © 2016 VanDao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YLSQLDataDefine.h"

@interface YLSQLCommand : NSObject

@property (readonly) NSString *sqlCommand;

/**
 *  Initializes `YLSQLCommand` object with specifier SQL command
 *
 *  @param sql The sql command
 *
 *  @return The initialization `YLSQLCommand` object
 */
- (instancetype)initWithString:(NSString *)sql;

/**
 *  Initializes `YLSQLCommand` object with specifier format and parameter in va_list
 *
 *  @param format The format of sql command
 *
 *  @return The initialization `YLSQLCommand` object
 */
- (instancetype)initWithFormat:(NSString *)format, ...;

/**
 *  Initalizes `YLSQLCommand` object with specifier format and parameters in dictionary
 *
 *  @param command    The format of sql command
 *  @param parameters The dictionary contain parameters in sql command
 *
 *  @return The initialization `YLSQLCommand` object
 */
- (instancetype)initWithCommand:(NSString *)command withParametersInDictionary:(NSDictionary *)parameters;

/**
 *  Initializes `YLSQL Command` object with specifier format and parameters in array
 *
 *  @param command    The format of sql command
 *  @param parameters An array contain patameter in sql command
 *
 *  @return The initialization `YLSQLCOmmand` object
 */
- (instancetype)initWithCommand:(NSString *)command withParametersInArray:(NSArray *)parameters;

/**
 *  Creates and returns `YLSQLCommand` object with format and list of parameters.
 *
 *  @param format The format of sql command, 
 *
 *  @return The newly `YLSQLCommand` object
 */
+ (instancetype)SQLCommandWithFormat:(NSString *)format, ...;

/**
 *  Creates and returns `YLSQLCommand` object with format and specified dictionary contain parameters.
 *
 *  @param format     The format of sql command
 *  @param parameters The dictionary contain parameter in sql command
 *
 *  @return The newly `YLSQLCommand` object
 */
+ (instancetype)SQLCommand:(NSString *)format withParametersInDictionnary:(NSDictionary *)parameters;

/**
 *  Create and returns `YLSQLCommand` object with format and specified list of parameter
 *
 *  @param format     The format of sqlcommand
 *  @param parameters The array contain list of parameter in sql command
 *
 *  @return The newly `YLSQLCommand` object
 */
+ (instancetype)SQLCommand:(NSString *)format withParametersInArray:(NSArray *)parameters;

@end

#pragma YLSQLCommand + SQLiteStatement

@interface YLSQLCommand (SQLiteStatement)

/**
 *  Bind sql command of YLSQLCommand to sqlite_stmt an return
 *
 *  @return The `sqlite3_stmt` object if bind finish successfully, otherwise, return NULL
 */
- (sqlite3_stmt *)createSQLStatementFromDatabase:(sqlite3 *)database;

@end
