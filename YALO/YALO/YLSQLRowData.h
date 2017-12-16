//
//  YLSQLRowData.h
//  YALO
//
//  Created by VanDao on 8/5/16.
//  Copyright © 2016 admin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YLSQLDataDefine.h"

@interface YLSQLRowData : NSObject

@property (readonly) NSMutableDictionary *rowData;

/**
 *  Initialize a `YLSQLRowData` object with specifier row data
 *
 *  @param dictionary The dictionary row data
 *
 *  @return The initialization `YLSQLRowData` object
 */
- (instancetype)initWithDictionary:(NSDictionary *)dictionary;

/**
 *  Creates and returns a `YLSQLRowData` object with specifier row data
 *
 *  @param dictionary The dictionary row data
 *
 *  @return The newly `YLSQLRowData` object
 */
+ (instancetype)YLSQLRowDataWithDictionary:(NSDictionary *)dictionary;

/**
 *  Add a given columnName - `YLSQLDataValue` value pair to the YLSQLRowData
 *
 *  @param data       The data for column.
 *  @param columnName The name of column
 */
- (void)setData:(YLSQLDataValue *)data forColumn:(NSString *)columnName;

/**
 *  Returns the data associated with a given column name
 *
 *  @param columnName The column name for which to return the corressponding data
 *
 *  @return The data associated with column name, or nil if no data is associated with column name.
 */
- (YLSQLDataValue *)dataOfColumn:(NSString *)columnName;

/**
 *  Add a given item to YLSQLRowData
 *
 *  @param newItem The `YLSQLDataItem` object
 */
- (void)addNewItem:(YLSQLDataItem *)newItem;

/**
 *  Return the item associated with a given column name
 *
 *  @param columnName The column name for which to return the coressponding item
 *
 *  @return The item associated with column name, or nil if no item is associated with column name
 */
- (YLSQLDataItem *)itemOfColumn:(NSString *)columnName;

/**
 *  List of column name
 *
 *  @return The list of column name in `YLSQLRowData`
 */
- (NSArray<NSString *> *)allColumns;

/**
 *  Return a Boolean value that indicates wherever the `YLSQLRowData` receiver and a given `YLSQLRowData` object are equal
 *
 *  @param rowData The `YLSQLRowData` object to be compared to the receiver. My be nil, in which case this method returns NO
 *
 *  @return YES if the receiver and anObject are equal, otherwise NO
 */
- (BOOL)isEqual:(YLSQLRowData *)rowData;

@end
