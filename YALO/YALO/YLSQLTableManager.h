//
//  YLSQLTableManager.h
//  YALO
//
//  Created by VanDao on 8/4/16.
//  Copyright © 2016 admin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YLSQLDatabase.h"
#import "YLSQLDataDefine.h"
#import "YLSQLColumnAttributes.h"
#import "YLSQLRowData.h"

@class YLSQLTableColumnAttributes;

@interface YLSQLTableManager : NSObject

@property (readonly) NSString *tableName;
@property (readonly) YLSQLDatabase *database;
@property (readonly) NSMutableArray<YLSQLColumnAttributes *>* listOfColumnAttributes;

/**
 *  Creates and returns a `YLSQLTableManager` object with specifier table name and database
 *
 *  @param tableName The name of the table in database
 *  @param database  The `YLSQLDatabase` object
 *
 *  @return The newly `YLSQLTableManager` object
 */
+ (instancetype)YLSQLTableManagerWithTableName:(NSString *)tableName inDatabase:(YLSQLDatabase *)database;

/**
 *  Initialize a `YLSQLTableManager` object with specifier table name and database
 *
 *  @param tableName The nameof the table indatabase
 *  @param database  The `YLSQLDatabse` object
 *
 *  @return The initialization `YLSQLTableManager` object
 */
- (instancetype)initWithTableName:(NSString *)tableName inDatabase:(YLSQLDatabase *)database;

/**
 *  Insert new row to table in database
 *
 *  @param row The row data
 *
 *  @return YES if insert finish successfully, otherwise, return NO
 */
- (BOOL)insertNewRow:(YLSQLRowData *)row;

/**
 *  Update all data of specifier row by new data with specifier condition
 *
 *  @param newRow       The new data of row
 *  @param pairValue    The dictionary define the value and column name
 *
 *  @return YES if update finish successfully, otherwise, return NO
 */
- (BOOL)updateRow:(YLSQLRowData *)newRow where:(NSString *)whereCommand;

/**
 *  Delete rows in table with specifier condition
 *
 *  @param whereCommand The condition of DELETE command
 *
 *  @return YES if delete finish successfully, otherwise, return NO
 */
- (BOOL)deleteRowWhere:(NSString *)whereCommand;

/**
 *  Clean all data in table, and insert new data with specifier list of row data
 *
 *  @param newDataArray The list of row data will be updated
 *
 *  @return YES if update successfully, otherwise, return NO
 */
- (BOOL)replaceAllDataWithNewData:(NSArray *)newDataArray;

@end


