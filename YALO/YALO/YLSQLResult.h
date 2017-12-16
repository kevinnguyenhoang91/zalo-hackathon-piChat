//
//  YLSQLResult.h
//  SQLiteSummary
//
//  Created by VanDao on 8/2/16.
//  Copyright © 2016 VanDao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YLSQLColumnAttributes.h"

@interface YLSQLResult : NSObject

@property (readonly) NSArray<NSDictionary *> *data;

+ (instancetype)YLSQLResultWithArray:(NSArray *)array;

/**
 *  Get list of column name in result.
 *
 *  @return List of column name
 */
- (NSArray *)getListOfColumnName;

/**
 *  Get a row at specified index in result
 *
 *  @param index Index of row in result
 *
 *  @return The dictionary contains the row.
 */
- (NSDictionary *)rowAtIndex:(NSUInteger)index;

/**
 *  Get a column with specified column name in result.
 *
 *  @param columnName The name of the column in result
 *
 *  @return The array contains column
 */
- (NSArray *)rowsForColumnName:(NSString *)columnName;

@end
