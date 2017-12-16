//
//  YLSortDescription.m
//  YALO
//
//  Created by VanDao on 8/8/16.
//  Copyright © 2016 admin. All rights reserved.
//

#import "YLSortDescription.h"

@implementation YLSortDescription

- (instancetype)initWithPropertyName:(NSString *)propertyName isAcsending:(BOOL)isAcsending {
    self = [super init];
    
    if (self) {
        _propertyName = propertyName;
        _isAscending = isAcsending;
    }
    
    return self;
}

+ (instancetype)sortWithPropertyName:(NSString *)propertyName byAcsending:(BOOL)isAscending {
    
    return [[self alloc] initWithPropertyName:propertyName isAcsending:isAscending];
}

@end
