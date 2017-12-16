//
//  YLSortDescription.h
//  YALO
//
//  Created by VanDao on 8/8/16.
//  Copyright © 2016 admin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface YLSortDescription : NSObject

@property (readonly) NSString *propertyName;
@property (readonly) BOOL isAscending;

+ (instancetype)sortWithPropertyName:(NSString *)propertyName byAcsending:(BOOL)isAscending;

@end
