//
//  YLSQLColumnAttributes.h
//  YALO
//
//  Created by VanDao on 8/4/16.
//  Copyright © 2016 admin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YLSQLDataDefine.h"

static const NSString *YLColumnAttributeID = @"cID";
static const NSString *YLColumnAttributeName = @"cName";
static const NSString *YLColumnAttributeType = @"cType";
static const NSString *YLColumnAttributeNullable = @"cNullable";
static const NSString *YLColumnAttributeDefaultValue = @"cDefaultValue";
static const NSString *YLColumnAttributePrimaryKey = @"cPrimaryKey";


#define isKindOfObject(value) _Generic(value, id:YES, default: NO)

@interface YLSQLColumnAttributes : NSObject

@property(assign)       NSInteger       cID;
@property               NSString        *cName;
@property               YLSQLDataType   cType;
@property(assign)       BOOL            cNullable;
@property               YLSQLDataValue  *cDefaultValue;
@property(assign)       BOOL            cPrimaryKey;

/**
 *  Initialize a `YLSQLColumnAttribute` object with specifier column attributes in dictionary
 *
 *  @param dictionary The dictionary that a key-value pair within a dictionary is called an entry. Each entry consists of one object that represents the key is name of column attribute and a second object that is that column attribute’s value. Within a dictionary, the keys are unique
 *
 *      Example:    @{
                        YLColumnAttributeID :               0,                           // id of column
                        YLColumnAttributeName :             @"column1",                  // name of column
                        YLColumnAttributeType :             @(YLSQLDataTypeInteger),     // type of column
                        YLColumnAttributePrimary   :        @(YES),                      // column is primary key
                        YLColumnAttributeNullable :         @(YES),                      // column can be null
                        YLColumnAttributeDefaultValue :     @(5),                        // default value of column
                    }
 *
 *
 *  @return The initialization `YLSQLColumnAttributes` object
 */
- (instancetype)initWithDictionary:(NSDictionary *)dictionary;

/**
 *  Creates an return a `YLSQLColumnAttribute` object with specifier column attribute in dictionary
 *  @param dictionary The dictionary that a key-value pair within a dictionary is called an entry. Each entry consists of one object that represents the key is name of column attribute and a second object that is that column attribute’s value. Within a dictionary, the keys are unique
 *
 *      Example:    @{
                        YLColumnAttributeID :               0,                          // id of column
                        YLColumnAttributeName :             @"column12",                // name of column
                        YLColumnAttributeType :             @(YLSQLDataTypeString),     // type of column
                        YLColumnAttributePrimary   :        @(YES),                     // column is primary key
                        YLColumnAttributeNullable :         @(NO),                      // column can be null
                        YLColumnAttributeDefaultValue :     @"Default value",           // default value of column
                    }
 *
 *  @return The newly `YLSQLColumnAttributes` object
 */
+ (instancetype)columnAttributeWithDictionary:(NSDictionary *)dictionary;

@end