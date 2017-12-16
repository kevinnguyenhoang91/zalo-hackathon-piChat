//
//  YLExpression.h
//  YALO
//
//  Created by VanDao on 8/12/16.
//  Copyright © 2016 admin. All rights reserved.
//

#import "YLSQLCommand.h"

@interface YLExpression : NSObject

@property (readonly) NSString *sqlExpression;

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
- (instancetype)initWithFormat:(NSString *)format withParametersInDictionary:(NSDictionary *)parameters;

/**
 *  Initializes `YLSQL Command` object with specifier format and parameters in array
 *
 *  @param command    The format of sql command
 *  @param parameters An array contain patameter in sql command
 *
 *  @return The initialization `YLSQLCOmmand` object
 */
- (instancetype)initWithFormat:(NSString *)format withParametersInArray:(NSArray *)parameters;

/**
 *  Creates and returns `YLSQLCommand` object with format and list of parameters.
 *
 *  @param format The format of sql command,
 *
 *  @return The newly `YLSQLCommand` object
 */
+ (instancetype)expressionWithFormat:(NSString *)format, ...;

/**
 *  Creates and returns `YLSQLCommand` object with format and specified dictionary contain parameters.
 *
 *  @param format     The format of sql command
 *  @param parameters The dictionary contain parameter in sql command
 *
 *  @return The newly `YLSQLCommand` object
 */
+ (instancetype)expressionWithFormat:(NSString *)format withParametersInDictionnary:(NSDictionary *)parameters;

/**
 *  Create and returns `YLSQLCommand` object with format and specified list of parameter
 *
 *  @param format     The format of sqlcommand
 *  @param parameters The array contain list of parameter in sql command
 *
 *  @return The newly `YLSQLCommand` object
 */
+ (instancetype)expressionWithFormat:(NSString *)format withParametersInArray:(NSArray *)parameters;


@end
