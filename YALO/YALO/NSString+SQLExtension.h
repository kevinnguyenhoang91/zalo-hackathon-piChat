//
//  NSString+SQLExtension.h
//  YALO
//
//  Created by VanDao on 8/15/16.
//  Copyright © 2016 admin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (SQLExtension)

+ (NSString *)stringWithFormat:(NSString *)format withParametersInDictionnary:(NSDictionary *)parameters;

+ (NSString *)stringWithFormat:(NSString *)format withParametersInArray:(NSArray *)parameters;

@end
