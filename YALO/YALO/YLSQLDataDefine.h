//
//  YLSQLData.h
//  YALO
//
//  Created by VanDao on 8/4/16.
//  Copyright © 2016 admin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "sqlite3.h"

/**
 *  Define data type of column in sqlite
 */
typedef NS_ENUM(NSUInteger, YLSQLDataType) {
    /**
     *  INT, INTEGER, TINIINT, SMALLINT, MEDIUMINT, BIGINT, UNSIGNED BIG INT, INT2, INT8
     */
    YLSQLDataTypeInteger = SQLITE_INTEGER,
    /**
     *  REAL DOUBLE, DOUBLE PRECISION, FLOAT
     */
    YLSQLDataTypeDouble = SQLITE_FLOAT,
    /**
     *  BLOB NO DATATYPE SPECIFIED
     */
    YLSQLDataTypeData = SQLITE_BLOB,
    /**
     *  CHARACTER(20), VACHAR(255), VARYING CHARACTER(255, NCHAR(55), NATIVE CHARACTER(70), NVACHAR(100), TEXT CLOB
     */
    YLSQLDataTypeString = SQLITE_TEXT,
    
    /**
     *  NULL
     */
    YLSQLDataTypeNull = SQLITE_NULL,
};


#pragma YLSQLDataTypeConverter interface

@interface YLSQLDataTypeConverter : NSObject

+ (YLSQLDataType)dataTypeWithCodeType:(int)code;

+ (YLSQLDataType)dataTypeWithStringType:(NSString *)typeString;

+ (YLSQLDataType)dataTypeWithPropertyType:(NSString *)propertyType;

+ (int)codeTypeFromYLSQLDataType:(YLSQLDataType)dataType;

+ (NSString *)stringTypeFromYLSQLDataType:(YLSQLDataType)dataType;

+ (Class)classFromYLSQLDataType:(YLSQLDataType)dataType;

@end

#pragma YLSQLDataValue interface

@interface YLSQLDataValue : NSObject

@property (readonly) NSString *rawValue;

/**
 *  Initialize an `YLSQLDatraValue` object with specifier string raw value
 *
 *  @param rawValue The NSString raw value
 *
 *  @return The initializaion `YLSQLDataValue` object
 */
- (instancetype)initWithRawValue:(NSString *)rawValue;

/**
 *  Initialize an `YLSQLDataValue` object with specifier UTF8 string raw value
 *
 *  @param rawValue The const char* raw value
 *
 *  @return The initialization `YLSQLDataValue` object
 */
- (instancetype)initWithUTF8RawValue:(const char *)rawValue;

/**
 *  Creates and returns an `YLSQLDataValue` object with specifier string raw value
 *
 *  @param rawValue The NSString raw value
 *
 *  @return The newly-`YLSQLDataValue` object
 */
+ (instancetype)valueWithRawValue:(NSString *)rawValue;

/**
 *  Creates and returns an `YLSQLDataValue` object with specifier UTF8 string raw value
 *
 *  @param rawValue The const char* raw value
 *
 *  @return The newly-`YLSQLDataValue` object
 */
+ (instancetype)valueWithUTF8RawValue:(const char *)rawValue;

/**
 *  Return integer value from raw value string
 *
 *  @return The integer values, if can't convert or raw value is nil, return nil
 */
- (NSNumber *)integerValue;

/**
 *  Return double value from raw value string
 *
 *  @return The double values, if can't convert or raw value is nil, return nil
 */
- (NSNumber *)doubleValue;

/**
 *  Return data value from raw value string
 *
 *  @return The data values, if can't convert or raw value is nil, return nil
 */
- (NSData *)dataValue;

/**
 *  Return string value from raw value string
 *
 *  @return The string values, if can't convert or raw value is nil, return nil
 */
- (NSString *)stringValue;

/**
 *  Compare 2 YLSQLDataValue
 *
 *  @param dataValue The second `YLSQLDataValue` object
 *
 *  @return YES if equal, otherwise, return NO
 */
- (BOOL)isEqual:(YLSQLDataValue *)dataValue;

@end

@interface YLSQLDataItem : YLSQLDataValue

@property (readonly) NSString *columnName;

/**
 *  Initialize an `YLSQLDatraValue` object with specifier raw value
 *
 *  @param rawValue The NSString raw value
 *
 *  @return The initializaion `YLSQLDataValue` object
 */
- (instancetype)initWithRawValue:(NSString *)rawValue inColumnName:(NSString *)columnName;

/**
 *  Creates and returns an `YLSQLDataValue` object with specifier raw value
 *
 *  @param rawValue The NSString raw value
 *
 *  @return The newly-`YLSQLDataValue` object
 */
+ (instancetype)YLSQLDataValueWithRawValue:(NSString *)rawValue inColumnName:(NSString *)columnName;

@end
