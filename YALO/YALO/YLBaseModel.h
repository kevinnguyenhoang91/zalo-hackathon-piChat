//
//  YLBaseModel.h
//  YALO
//
//  Created by VanDao on 8/8/16.
//  Copyright © 2016 admin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YLDatabaseManager.h"

#define YLPropertyName(property) NSStringFromSelector(@selector(property))
#define YLClassName(class) NSStringFromClass(class)
#define YLFieldName(class, property) [[class propertyDescriptionByPropertyName:YLPropertyName(property)] fieldName]

@interface YLBaseModel : NSObject


@end
