//
//  YLSQLData.m
//  YALO
//
//  Created by VanDao on 8/4/16.
//  Copyright © 2016 admin. All rights reserved.
//

#import "YLSQLDataDefine.h"

#pragma YLSQLDataTypeConverter interface

@implementation YLSQLDataTypeConverter

+ (YLSQLDataType)dataTypeWithCodeType:(int)code {
    
    YLSQLDataType dataType;
    
    switch (code) {
        case SQLITE_INTEGER:
            dataType = YLSQLDataTypeInteger;
            break;
            
        case SQLITE_FLOAT:
            dataType = YLSQLDataTypeDouble;
            break;
            
        case SQLITE_BLOB:
            dataType = YLSQLDataTypeData;
            break;
            
        case SQLITE_TEXT:
            dataType = YLSQLDataTypeString;
            break;
            
        case SQLITE_NULL:
            dataType = YLSQLDataTypeNull;
            break;
            
        default:
            dataType = YLSQLDataTypeString;
            break;
    }
    
    return dataType;
}

+ (YLSQLDataType)dataTypeWithStringType:(NSString *)typeString {
    
    YLSQLDataType dataType;
    
    if (!typeString)
        dataType = YLSQLDataTypeNull;
    else if ([typeString containsString:@"INT"])
        dataType = YLSQLDataTypeInteger;
    else if ([typeString containsString:@"DOUBLE"] || [typeString containsString:@"FLOAT"] || [typeString containsString:@"REAL"])
        dataType = YLSQLDataTypeDouble;
    else if ([typeString containsString:@"BLOB"])
        dataType = YLSQLDataTypeData;
    else
        dataType = YLSQLDataTypeString;
    
    return dataType;
}

+ (int)codeTypeFromYLSQLDataType:(YLSQLDataType)dataType {
    
    return dataType;
}

+ (NSString *)stringTypeFromYLSQLDataType:(YLSQLDataType)dataType {
    
    NSString *typeString;
    
    switch (dataType) {
        case YLSQLDataTypeInteger:
            typeString = @"INT";
            break;
            
        case YLSQLDataTypeDouble:
            typeString = @"REAL";
            break;
            
        case YLSQLDataTypeData:
            typeString = @"BLOB";
            break;
            
        case YLSQLDataTypeString:
            typeString = @"TEXT";
            break;
            
        case YLSQLDataTypeNull:
            typeString = nil;
            break;
            
        default:
            typeString = @"TEXT";
            break;
    }
    
    return typeString;
}

+ (YLSQLDataType)dataTypeWithPropertyType:(NSString *)propertyType {
    return 0;
}

+ (Class)classFromYLSQLDataType:(YLSQLDataType)dataType {
    
    Class classType;
    
    switch (dataType) {
        case YLSQLDataTypeInteger:
            classType = [NSNumber class];
            break;
            
        case YLSQLDataTypeDouble:
            classType = [NSNumber class];
            break;
            
        case YLSQLDataTypeData:
            classType = [NSData class];
            break;
            
        case YLSQLDataTypeString:
            classType = [NSString class];
            break;
            
        case YLSQLDataTypeNull:
            classType = [NSNull class];
            break;
            
        default:
            classType = [NSString class];
            break;
    }
    
    return classType;
}

@end

#pragma YLSQLDataValue implementation

@implementation YLSQLDataValue

- (instancetype)initWithRawValue:(NSString *)rawValue {
    
    self = [super init];
    
    if (self) {
        _rawValue = rawValue;
    }
    
    return self;
}

- (instancetype)initWithUTF8RawValue:(const char *)rawValue {
    
    self = [super init];
    
    if (self) {
        _rawValue = rawValue ? [NSString stringWithUTF8String:rawValue] : nil;
    }
    
    return self;
}

+ (instancetype)valueWithRawValue:(NSString *)rawValue {
    
    return [[self alloc]initWithRawValue:rawValue];
}

+ (instancetype)valueWithUTF8RawValue:(const char *)rawValue {
    
    return [[self alloc]initWithUTF8RawValue:rawValue];
}

- (NSNumber *)integerValue {
    
    return _rawValue ? [NSNumber numberWithLongLong:[_rawValue longLongValue]] : nil;
}

- (NSNumber *)doubleValue {
    
    return _rawValue ? [NSNumber numberWithDouble:[_rawValue doubleValue]] : nil;
}

- (NSData *)dataValue {
    
    return _rawValue ? [NSData dataWithBytes:[_rawValue UTF8String] length:strlen([_rawValue UTF8String])] : nil;
}

- (NSString *)stringValue {
    
    return _rawValue ? [NSString stringWithUTF8String:[_rawValue UTF8String]] : nil;
}

- (BOOL)isEqual:(YLSQLDataValue *)dataValue {
    
    return [_rawValue isEqual:dataValue.rawValue];
}

@end

@implementation YLSQLDataItem

- (instancetype)initWithRawValue:(NSString *)rawValue inColumnName:(NSString *)columnName {
    
    self = [super initWithRawValue:rawValue];
    
    if (self) {
        
        _columnName = columnName;
    }
    
    return self;
}

+ (instancetype)YLSQLDataValueWithRawValue:(NSString *)rawValue inColumnName:(NSString *)columnName {
    
    return [[self alloc]initWithRawValue:rawValue inColumnName:columnName];
}

@end


