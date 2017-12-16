//
//  YLSQLResultCursor.h
//  YALO
//
//  Created by Nguyen Van Dao on 8/3/16.
//  Copyright © 2016 admin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YLSQLDatabase.h"

@interface YLSQLResultCursor : NSObject

@property(readonly, weak) YLSQLDatabase *database;
@property(readonly) YLSQLCommand *sqlCommand;
@property (readonly) NSMutableArray<YLSQLColumnAttributes *>* listOfColumnAttributes;

/**
 *  Creates and returns a `YLSQLResultCursor` object with specifier command object in database object
 *
 *  @param sqlCommand The `YLSQLCommand` object
 *  @param database   The `YLSQLDatabase` object
 *
 *  @return The newly `YLSQLResultCursor` object
 */
+ (instancetype)resultCursorWithSQLCommand:(YLSQLCommand *)sqlCommand inDatabase:(YLSQLDatabase *)database;

/**
 *  Initialize a `YLSQLResultCursor` object with specifier command object in database object
 *
 *  @param sqlCommand The `YLSQLCommand` object
 *  @param database   The `YLSQLDatabase` object
 *
 *  @return The initialization `YLSQLResultCursor` object
 */
- (instancetype)initWithSQLCommand:(YLSQLCommand *)sqlCommand inDatabase:(YLSQLDatabase *)database;

/**
 *  Get current row data
 *
 *  @return The dictinary contain data of current row
 */
- (NSDictionary *)getCurrentRowResult;

/**
 *  Jump the cursor to next row
 *
 *  @return YES if jump finish successfully, otherwise, return NO
 */
- (BOOL)jumpToNextRow;

/**
 *  Get all rows in statement, and the next cursor will be in end position of the statement
 *
 *  @return All of row data in statement
 */
- (NSArray<NSDictionary *> *)getAllResultAndJumpCursorToEndRow;

/**
 *  Clean all data in result cursor, and reset the cursor jump to begin position of the statement
 */
- (void)clean;

@end
