//
//  NSString+SQLExtension.m
//  YALO
//
//  Created by VanDao on 8/15/16.
//  Copyright © 2016 admin. All rights reserved.
//

#import "NSString+SQLExtension.h"

@implementation NSString (SQLExtension)

+ (NSString *)stringWithFormat:(NSString *)format withParametersInDictionnary:(NSDictionary *)parameters {
    
    NSMutableString *string = [format mutableCopy];
    
    for (NSString *key in parameters.allKeys) {
        
        NSRange range = NSMakeRange(NSNotFound, 0);
        
        do {
            NSRange range = [string rangeOfString:[NSString stringWithFormat:@":%@", key] options:NSLiteralSearch];
            [string replaceCharactersInRange:range withString:[parameters objectForKey:key]];
        } while (range.location == NSNotFound);
    }
    
    return string;
}

+ (NSString *)stringWithFormat:(NSString *)format withParametersInArray:(NSArray *)parameters {
    
    NSMutableData *data = [NSMutableData dataWithLength:(sizeof(id) * parameters.count)];
    [parameters getObjects:(__unsafe_unretained id *)data.mutableBytes range:NSMakeRange(0, parameters.count)];
    
    return [self generateSQLCommandWithFormat:format inArrayParameter:parameters];
}

+ (NSString *)generateSQLCommandWithFormat:(NSString *)sql inArrayParameter:(NSArray *)arguments {
    
    unichar last = '\0';
    NSInteger index = 0;
    NSMutableString *sqlCommand = [sql mutableCopy];
    NSString *value;
    NSNumber *number;
    NSRange range;
    
    for (NSUInteger i = 0; i < sqlCommand.length; ++i) {
        
        unichar current = [sqlCommand characterAtIndex:i];
        if (last == '%') {
            range = NSMakeRange(0, 0);
            value = @"";
            
            switch (current) {
                case '%':
                    value = @"";
                    range = NSMakeRange(i, 1);
                    break;
                    
                case '@':
                case 'S':
                    value = [NSString stringWithFormat:[NSString stringWithFormat:@"%@%c",@"%", current], [arguments objectAtIndex:index++]];
                    range = NSMakeRange(i - 1, 2);
                    break;
                    
                case 'c':
                    number = [arguments objectAtIndex:index++];
                    value = [NSString stringWithFormat:[NSString stringWithFormat:@"%@%c",@"%", current], [number unsignedCharValue]];
                    range = NSMakeRange(i - 1, 2);
                    break;
                    
                case 's':
                    value = [NSString stringWithFormat:[NSString stringWithFormat:@"%@%c",@"%", current], [[arguments objectAtIndex:index++] UTF8String]];
                    range = NSMakeRange(i - 1, 2);
                    break;
                    
                case 'i':
                    number = [arguments objectAtIndex:index++];
                    value = [NSString stringWithFormat:[NSString stringWithFormat:@"%@%c",@"%", current], [number shortValue]];
                    range = NSMakeRange(i - 1, 2);
                    break;
                    
                case 'I':
                    number = [arguments objectAtIndex:index++];
                    value = [NSString stringWithFormat:[NSString stringWithFormat:@"%@%c",@"%", current], [number unsignedShortValue]];
                    range = NSMakeRange(i - 1, 2);
                    break;
                    
                case 'd':
                case 'D':
                    number = [arguments objectAtIndex:index++];
                    value = [NSString stringWithFormat:[NSString stringWithFormat:@"%@%c",@"%", current], [number integerValue]];
                    range = NSMakeRange(i - 1, 2);
                    break;
                    
                case 'x':
                case 'X':
                case 'o':
                case 'O':
                    number = [arguments objectAtIndex:index++];
                    value = [NSString stringWithFormat:[NSString stringWithFormat:@"%@%c",@"%", current], [number unsignedIntegerValue]];
                    range = NSMakeRange(i - 1, 2);
                    break;
                    
                case 'a':
                case 'A':
                case 'f':
                case 'F':
                case 'e':
                case 'E':
                case 'g':
                case 'G':
                    number = [arguments objectAtIndex:index++];
                    value = [NSString stringWithFormat:[NSString stringWithFormat:@"%@%c",@"%", current], [number doubleValue]];
                    range = NSMakeRange(i - 1, 2);
                    break;
                    
                case 'u':
                case 'U':
                    number = [arguments objectAtIndex:index++];
                    value = [NSString stringWithFormat:[NSString stringWithFormat:@"%@%c",@"%", current], [number unsignedIntegerValue]];
                    range = NSMakeRange(i - 1, 2);
                    break;
                    
                case 'h':
                    i++;
                    if (i < sqlCommand.length && ([sqlCommand characterAtIndex:i] == 'i' || [sqlCommand characterAtIndex:i] == 'u')) {
                        
                        value = [NSString stringWithFormat:[NSString stringWithFormat:@"%@%c",@"%h", current], [arguments objectAtIndex:index++]];
                        [sqlCommand replaceCharactersInRange:NSMakeRange(i - 2, 3) withString:value];
                        i = i - 2 + value.length;
                    } else {
                        i--;
                    }
                    break;
                    
                case 'q':
                    i++;
                    if (i < sqlCommand.length && ([sqlCommand characterAtIndex:i] == 'i'|| [sqlCommand characterAtIndex:i] == 'u')) {
                        
                        value = [NSString stringWithFormat:[NSString stringWithFormat:@"%@%c",@"%q", current], [arguments objectAtIndex:index++]];
                        [sqlCommand replaceCharactersInRange:NSMakeRange(i - 2, 3) withString:value];
                        i = i - 2 + value.length;
                    } else {
                        i--;
                    }
                    break;
                    
                case 'l':
                    i++;
                    if (i < sqlCommand.length) {
                        unichar next = [sqlCommand characterAtIndex:i];
                        if (next == 'l') {
                            i++;
                            if (i < sqlCommand.length && ([sqlCommand characterAtIndex:i] == 'd' || [sqlCommand characterAtIndex:i] == 'u')) {
                                
                                //%lld || %llu
                                number = [arguments objectAtIndex:index++];
                                value = [NSString stringWithFormat:[NSString stringWithFormat:@"%@%c",@"%l", next], [number longLongValue]];
                                range = NSMakeRange(i - 3, 4);
                                
                            }
                            else {
                                i--;
                            }
                        }
                        else if (next == 'd' || next == 'u' || next == 'i' || next == 'x') {
                            
                            //%ld || %lu
                            number = [arguments objectAtIndex:index++];
                            value = [NSString stringWithFormat:[NSString stringWithFormat:@"%@%c",@"%l", next], [number longValue]];
                            range = NSMakeRange(i - 2, 3);
                        }
                        else if (next == 'f') {
                            
                            //%ld || %lu
                            number = [arguments objectAtIndex:index++];
                            value = [NSString stringWithFormat:[NSString stringWithFormat:@"%@%c",@"%l", next], [number doubleValue]];
                            range = NSMakeRange(i - 2, 3);
                        }
                        else {
                            i--;
                        }
                    }
                    else {
                        i--;
                    }
                    break;
                    
                default:
                    // something else that we can't interpret. just pass it on through like normal
                    break;
            }
            
            if (range.length != 0) {
                [sqlCommand replaceCharactersInRange:range withString:value];
                i = i - range.length - 1 + value.length;
                
                if ([value isEqualToString:@""])
                    i++;
            }
        }
        
        last = current;
    }
    
    return sqlCommand;
}


@end
