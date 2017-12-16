//
//  YLSQLResult.m
//  SQLiteSummary
//
//  Created by VanDao on 8/2/16.
//  Copyright © 2016 VanDao. All rights reserved.
//

#import "YLSQLResult.h"

@implementation YLSQLResult

- (instancetype)initWithArray:(NSArray *)array {
    
    self = [super init];
    
    if (self) {
        _data = array;
    }
    
    return self;
}

+ (instancetype)YLSQLResultWithArray:(NSArray *)array {

    return [[self alloc]initWithArray:array];
}

- (NSArray *)getListOfColumnName {
    
    return [[_data objectAtIndex:0] allKeys];
}

- (NSDictionary *)rowAtIndex:(NSUInteger)index {
    
    return [_data objectAtIndex:index];
}

- (NSArray *)rowsForColumnName:(NSString *)columnName {
    
    NSMutableArray *value = [[NSMutableArray alloc]init];
    
    for (NSDictionary *row in _data) {
        [value addObject:[row objectForKey:columnName]];
    }
    
    return value;
}

@end
