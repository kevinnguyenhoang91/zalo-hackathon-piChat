//
//  YLSQLRowData.m
//  YALO
//
//  Created by VanDao on 8/5/16.
//  Copyright © 2016 admin. All rights reserved.
//

#import "YLSQLRowData.h"

@implementation YLSQLRowData

- (instancetype)init {
    
    self = [super init];
    
    if (self) {
        _rowData = [NSMutableDictionary dictionary];
    }
    
    return self;
}

- (instancetype)initWithDictionary:(NSDictionary *)dictionary {
    
    self = [super init];
    
    if (self) {
        
        _rowData = [dictionary mutableCopy];
    }
    
    return self;
}

+ (instancetype)YLSQLRowDataWithDictionary:(NSDictionary *)dictionary {
    
    return [[self alloc]initWithDictionary:dictionary];
}

- (void)setData:(YLSQLDataValue *)data forColumn:(NSString *)columnName {

    if (!columnName)
        return;
    
    [_rowData setObject:data.rawValue ? data.rawValue : [NSNull null] forKey:columnName];
}

- (YLSQLDataValue *)dataOfColumn:(NSString *)columnName {
    
    return [YLSQLDataValue valueWithRawValue: [_rowData objectForKey:columnName]];
}

- (void)addNewItem:(YLSQLDataItem *)newItem {
    
    [_rowData setObject:newItem.rawValue ? newItem.rawValue : [NSNull null] forKey:newItem.columnName];
}

- (YLSQLDataItem *)itemOfColumn:(NSString *)columnName {
    
    return [YLSQLDataItem YLSQLDataValueWithRawValue:[_rowData objectForKey:columnName] inColumnName:columnName];
}

- (BOOL)isEqual:(YLSQLRowData *)rowData {
    
    if (!rowData || (rowData && rowData.rowData.count != _rowData.count))
        return NO;
    
    NSArray *allSelfColumnName = [_rowData allKeys];
    NSArray *allColumnName = [rowData.rowData allKeys];
    
    for (NSString *columnName in allSelfColumnName) {
        
        if (![allColumnName containsObject:columnName])
            return NO;
        
        if (![[self dataOfColumn:columnName] isEqual:[rowData dataOfColumn:columnName]])
            return NO;
    }
    
    return YES;
}

- (NSArray<NSString *> *)allColumns {
    
    return [_rowData.allKeys copy];
}

@end
