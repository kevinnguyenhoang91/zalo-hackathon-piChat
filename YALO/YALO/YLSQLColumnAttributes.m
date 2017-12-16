//
//  YLSQLColumnAttributes.m
//  YALO
//
//  Created by VanDao on 8/4/16.
//  Copyright © 2016 admin. All rights reserved.
//

#import "YLSQLColumnAttributes.h"

@implementation YLSQLColumnAttributes

- (instancetype)init {
    
    self = [super init];
    
    if (self) {
        
        _cID = 0;
        _cName = nil;
        _cType = YLSQLDataTypeInteger;
        _cNullable = NO;
        _cDefaultValue = [YLSQLDataValue valueWithRawValue:nil];
        _cPrimaryKey = NO;
    }
    
    return self;
}

- (instancetype)initWithDictionary:(NSDictionary *)dictionary {
    
    self = [self init];
    
    if (self) {
        
        _cID = [(NSNumber *)[dictionary objectForKey:YLColumnAttributeID] integerValue];
        _cName = [dictionary objectForKey:YLColumnAttributeName];
        _cType = [(NSNumber *)[dictionary objectForKey:YLColumnAttributeType] integerValue];
        _cNullable = [(NSNumber *)[dictionary objectForKey:YLColumnAttributeNullable] boolValue];
        _cPrimaryKey = [(NSNumber *)[dictionary objectForKey:YLColumnAttributePrimaryKey] boolValue];
        _cDefaultValue = [dictionary objectForKey:YLColumnAttributeDefaultValue];
    }
    
    return self;
}


+ (instancetype)columnAttributeWithDictionary:(NSDictionary *)dictionary {
    
    return [[self alloc]initWithDictionary:dictionary];
}

@end
