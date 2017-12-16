//
//  YLSQLTableManager.m
//  YALO
//
//  Created by VanDao on 8/4/16.
//  Copyright © 2016 admin. All rights reserved.
//

#import "YLSQLTableManager.h"

#pragma YLSQLTableManager implementation

@interface YLSQLTableManager()

@end

@implementation YLSQLTableManager

- (instancetype)init {
    
    self = [super init];
    
    if (self) {
        _listOfColumnAttributes = [[NSMutableArray alloc]init];
    }
    
    return self;
}

+ (instancetype)YLSQLTableManagerWithTableName:(NSString *)tableName inDatabase:(YLSQLDatabase *)database {
    
    return [[self alloc]initWithTableName:tableName inDatabase:database];
}

- (instancetype)initWithTableName:(NSString *)tableName inDatabase:(YLSQLDatabase *)database {
    
    self  = [super init];
    
    if (self) {
        
        // Connect to table database
        _tableName = tableName;
        _database = database;
        
        // Get connect to table
        [_database executeQueryCommand:[YLSQLCommand SQLCommandWithFormat:@"PRAGMA table_info(%@)", tableName] withCompletionHandler:^(NSError *error, YLSQLResult *result) {
            
            for (NSDictionary *column in result.data) {
                YLSQLColumnAttributes *columnAttribues = [[YLSQLColumnAttributes alloc]init];
                YLSQLDataValue *tempValue;
                
                // Column ID
                tempValue = [YLSQLDataValue valueWithRawValue:[column objectForKey:[NSString stringWithUTF8String:"cid"]]];
                columnAttribues.cID = [[tempValue integerValue] integerValue];
                
                // Column Name
                tempValue = [YLSQLDataValue valueWithRawValue:[column objectForKey:[NSString stringWithUTF8String:"name"]]];
                columnAttribues.cName = [tempValue stringValue];
                
                // Column Type
                tempValue = [YLSQLDataValue valueWithRawValue:[column objectForKey:[NSString stringWithUTF8String:"type"]]];
                columnAttribues.cType = [YLSQLDataTypeConverter dataTypeWithStringType:[tempValue stringValue]];
                
                // Column is Not null
                tempValue = [YLSQLDataValue valueWithRawValue:[column objectForKey:[NSString stringWithUTF8String:"notnull"]]];
                columnAttribues.cNullable = tempValue.rawValue ? YES : NO;
                
                // Column default value
                tempValue = [YLSQLDataValue valueWithRawValue:[column objectForKey:[NSString stringWithUTF8String:"dflt_value"]]];
                columnAttribues.cDefaultValue = tempValue;
                
                // Column is priamry key
                tempValue = [YLSQLDataValue valueWithRawValue:[column objectForKey:[NSString stringWithUTF8String:"pk"]]];
                columnAttribues.cPrimaryKey = tempValue.rawValue ? YES : NO;
                
                [_listOfColumnAttributes addObject:columnAttribues];
            }
        } onQueue:nil];
    }
    
    return self;
}

- (BOOL)insertNewRow:(YLSQLRowData *)row {

    return NO;
}

- (BOOL)updateRow:(YLSQLRowData *)newRow where:(NSString *)whereCommand {
    
    return NO;
}

- (BOOL)deleteRowWhere:(NSString *)whereCommand {
    
    return NO;
}

- (BOOL)replaceAllDataWithNewData:(NSArray *)newDataArray {
    
    return NO;
}

int YLSQLColumnAttributesCallbackFunction(void *resultArray, int columns, char **values, char **colNames) {
    
    if (!resultArray)
        return SQLITE_OK;
    
    NSMutableDictionary *rowData = [[NSMutableDictionary alloc]init];
    
    for(int i = 0; i < columns; i++) {
        NSString *temp = values[i] ? [NSString stringWithUTF8String:values[i]] : nil;
        [rowData setObject:(temp ? temp : [NSNull null]) forKey:[NSString stringWithUTF8String: colNames[i]]];
    }
    
    [(__bridge NSMutableArray *)resultArray addObject: rowData];
    
    return 0;
}

@end