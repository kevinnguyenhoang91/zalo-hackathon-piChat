//
//  YLExpression.m
//  YALO
//
//  Created by VanDao on 8/12/16.
//  Copyright © 2016 admin. All rights reserved.
//

#import "YLExpression.h"
#import "NSString+SQLExtension.h"

@implementation YLExpression

- (instancetype)initWithString:(NSString *)sql {
    self = [super init];
    
    if (self) {
        _sqlExpression = sql;
    }
    
    return self;
}

- (instancetype)initWithFormat:(NSString *)format, ... {
    
    self = [super init];
    
    if (self) {
        
        va_list args;
        va_start(args, format);
        
        _sqlExpression = [[NSString alloc]initWithFormat:format arguments:args];
        
        va_end(args);
    }
    
    return self;
}

- (instancetype)initWithFormat:(NSString *)format withParametersInDictionary:(NSDictionary *)parameters {
    self = [super init];
    
    if (self) {
        _sqlExpression = [NSString stringWithFormat:format withParametersInDictionnary:parameters];
    }
    
    return self;
}

- (instancetype)initWithFormat:(NSString *)format withParametersInArray:(NSArray *)parameters {
    self = [super init];
    
    if (self) {
        _sqlExpression = [NSString stringWithFormat:format withParametersInArray:parameters];
    }
    
    return self;
}


+ (instancetype)expressionWithFormat:(NSString *)format, ... {
    
    va_list args;
    va_start(args, format);
    NSString *sqlCommand = [[NSString alloc]initWithFormat:format arguments:args];
    va_end(args);
    
    return [[self alloc]initWithString:sqlCommand];
}


+ (instancetype)expressionWithFormat:(NSString *)format withParametersInDictionnary:(NSDictionary *)parameters {
    
    return [[self alloc] initWithFormat:format withParametersInDictionary:parameters];
}


+ (instancetype)expressionWithFormat:(NSString *)format withParametersInArray:(NSArray *)parameters {
    
    return [[self alloc] initWithFormat:format withParametersInArray:parameters];
}


@end
