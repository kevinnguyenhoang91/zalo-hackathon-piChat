//
//  YLDatabaseManager.m
//  YALO
//
//  Created by VanDao on 8/9/16.
//  Copyright © 2016 admin. All rights reserved.
//

#import "YLDatabaseManager.h"
#import "YLDatabaseQueue.h"
#import "YLBaseModel.h"
#import <objc/runtime.h>

#define kPropertyName @"Name"
#define kPropertyType @"Type"

@interface YLDatabaseManager ()

@property (nonatomic) dispatch_queue_t internalSerialQueue;
@property (nonatomic) NSMutableDictionary *propertyCache;

@end

@implementation YLDatabaseManager

- (instancetype)init {
    
    self  = [super init];
    
    if (self) {
        _internalSerialQueue = dispatch_queue_create("com.YALO.DatabaseManager", 0);
        _propertyCache = [NSMutableDictionary dictionary];
    }
    
    return self;
}

- (instancetype)initWithPath:(NSString *)path {

    self = [self init];
    
    if (self) {
        _dbConnection = [YLSQLDatabase databaseWithPath:path];
    }
    
    return self;
}

- (void)createTableForClass:(Class)className withPrimaryKey:(NSArray *)propertyNameArray {
    
    NSArray *properties = [self fetchPropertiesDescriptionForClass:className];

    NSMutableString *sqlString = [NSMutableString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@ (", YLClassName([self getClassTableForClass:className])];
    for (NSInteger index = 0; index < properties.count; index++) {
        NSString *propertyName = [properties[index] objectForKey:kPropertyName];
        NSString *propertyType = [properties[index] objectForKey:kPropertyType];
        NSString *isNullable = [self checkIfString:propertyName containInArray:propertyNameArray] ? @"NOT NULL" : @"";
        
        [sqlString insertString:[NSString stringWithFormat:@"%@ %@ %@ %@", propertyName, propertyType, isNullable, @", "] atIndex:sqlString.length];
    }
    if (propertyNameArray) {
        [sqlString insertString:[NSString stringWithFormat:@"PRIMARY KEY (%@) );", [propertyNameArray componentsJoinedByString:@","]] atIndex:sqlString.length];
    }
    
    [_dbConnection executeCommand:[YLSQLCommand SQLCommandWithFormat:sqlString,nil]];
}

- (Class)getClassTableForClass:(Class)className {
    
    Class class = className;
    
    while (![YLClassName([class superclass]) isEqualToString:YLClassName([YLBaseModel class])]) {
        class = [class superclass];
    }
    
    return class;
}

- (BOOL)checkIfString:(NSString *)string containInArray:(NSArray *)array {
    
    for (NSString *aString in array) {
        if ([string isEqualToString:aString])
            return YES;
    }
    
    return NO;
}

- (NSArray *)fetchAllObjectForClass:(Class)className {
    
    return [self fetchObjectForClass:className withMatching:nil];
}

- (NSArray *)fetchObjectForClass:(Class)className withMatching:(YLExpression *)expression {
    
    return [self fetchObjectForClass:className withMatching:expression sortDesciption:nil];
}

- (NSArray *)fetchObjectForClass:(Class)className withMatching:(YLExpression *)expression sortDesciption:(NSArray<YLSortDescription *>*)sortDescriptions {
    
    NSMutableString *sqlCommand = [NSMutableString stringWithFormat:@"SELECT * FROM %@", NSStringFromClass(className)];
    
    if (expression) {
        
        [sqlCommand insertString:[NSString stringWithFormat:@" WHERE %@", expression.sqlExpression] atIndex:sqlCommand.length];
    }
    
    if (sortDescriptions && sortDescriptions.count > 0) {
        
        [sqlCommand insertString:@" ORDER BY " atIndex:sqlCommand.length];
        
        for (int i = 0; i < sortDescriptions.count; ++i) {
            
            if (i > 0) {
                [sqlCommand insertString:@", " atIndex:sqlCommand.length];
            }
            YLSortDescription *sortDescription = sortDescriptions[i];
            
            [sqlCommand insertString:sortDescription.propertyName atIndex:sqlCommand.length];
            
            if (sortDescription.isAscending) {
                [sqlCommand insertString:@" ASC" atIndex:sqlCommand.length];
            }
            else
                [sqlCommand insertString:@" DESC" atIndex:sqlCommand.length];
        }
        
        [sqlCommand insertString:@";" atIndex:sqlCommand.length];
    }
    
    return [self fetchObjectFromQueryCommand:[[YLSQLCommand alloc]initWithString:sqlCommand]];
}

- (NSArray *)fetchObjectFromQueryCommand:(YLSQLCommand *)command {
    
    YLSQLResult *result = [_dbConnection executeQueryCommand:command];
    
    return result.data;
}

- (BOOL)saveObjects:(NSArray *)objects {
    
    [_dbConnection beginTransaction];
    
    BOOL res = YES;
    for (id object in objects) {
        if (![_dbConnection executeCommand:[self insertStatementForClass:[object class] withObjectsInArray:@[object]]]) {
            res = NO;
            break;
        }
    }
    
    if (res)
        [_dbConnection commitTransaction];
    else
        [_dbConnection rollbackTransaction];

    return res;
}

- (YLSQLCommand *)insertStatementForClass:(Class)className withObjectsInArray:(NSArray *)array {
    
    NSArray *properties = [self fetchPropertiesDescriptionForClass:[self getClassTableForClass:className]];
    NSMutableArray *propertiesName = [NSMutableArray array];
    for (NSDictionary *property in properties) {
        [propertiesName addObject:[property objectForKey:kPropertyName]];
    }
    
    NSMutableString *sqlString = [NSMutableString stringWithFormat:@"INSERT OR REPLACE INTO %@ (%@) VALUES ", YLClassName([self getClassTableForClass:className]), [propertiesName componentsJoinedByString:@", "]];
    
    for (NSInteger index = 0; index < [array count]; index++) {
        
        id object = [array objectAtIndex:index];
        NSMutableArray *value = [NSMutableArray array];
        
        for (NSDictionary *property in properties) {
            
            id propertyValue = [object valueForKey:[property objectForKey:kPropertyName]];
            NSString *stringValue = @"NULL";
            
            if (propertyValue) {
                if ([[property objectForKey:kPropertyType] isEqualToString:[YLSQLDataTypeConverter stringTypeFromYLSQLDataType:YLSQLDataTypeInteger]] ||
                    [[property objectForKey:kPropertyType] isEqualToString:[YLSQLDataTypeConverter stringTypeFromYLSQLDataType:YLSQLDataTypeDouble]]) {
                    
                    stringValue = [[NSArray arrayWithObject:propertyValue] componentsJoinedByString:@""];
                }
                else {
                    
                    stringValue = [NSString stringWithFormat:@"'%@'", [[NSArray arrayWithObject:propertyValue] componentsJoinedByString:@""]];
                }
            }
            
            [value addObject:stringValue];
        }
        [sqlString insertString:[NSString stringWithFormat:@"(%@)", [value componentsJoinedByString:@", "]] atIndex:sqlString.length];
        [sqlString insertString:(index == [array count] - 1) ? @";" : @"," atIndex:sqlString.length];
    }
    
    return [[YLSQLCommand alloc] initWithString:sqlString];
}

- (BOOL)deleteAllObjectsForClass:(Class)className {
    
    [_dbConnection beginTransaction];
    
    BOOL res = [_dbConnection executeCommand:[YLSQLCommand SQLCommandWithFormat:@"DELETE FROM %@", YLClassName([self getClassTableForClass:className])]];

    if (res)
        [_dbConnection commitTransaction];
    else
        [_dbConnection rollbackTransaction];
    
    return res;
}

- (NSArray *)fetchPropertiesDescriptionForClass:(Class)className {
    
    NSMutableArray *propertiesList = [_propertyCache objectForKey:YLClassName([self getClassTableForClass:className])];
    
    if (!propertiesList) {
        
        unsigned int numberOfProperties;
        objc_property_t *properties = class_copyPropertyList(className, &numberOfProperties);

        propertiesList = [NSMutableArray array];
        
        for (int i = 0; i < numberOfProperties; i++)
        {
            NSString *propertyName = [NSString stringWithUTF8String:property_getName(properties[i])];
            NSString *propertyType = [NSString stringWithUTF8String:property_copyAttributeList(properties[i], 0)->value];
            
            if ([propertyName characterAtIndex:0] != '_' &&
                !([propertyName isEqualToString:@"hash"] ||
                  [propertyName isEqualToString:@"superclass"] ||
                  [propertyName isEqualToString:@"description"] ||
                  [propertyName isEqualToString:@"debugDescription"])
                ) {
                
                [propertiesList addObject:@{
                                            kPropertyName: propertyName,
                                            kPropertyType: [self getPropertyTypeFromString:propertyType],
                                            }];
            }
        }
        
        free(properties);
    }
    
    return propertiesList;
}

- (NSString *)getPropertyTypeFromString:(NSString *)type {
    
    NSString *propertyType = nil;
    
    if ([type containsString:@"@\"NS"]) {
        
        if ([type containsString:@"@\"NSNumber\""])
            propertyType = [YLSQLDataTypeConverter stringTypeFromYLSQLDataType:YLSQLDataTypeDouble];
        else if ([type containsString:@"@\"NSData\""])
            propertyType = [YLSQLDataTypeConverter stringTypeFromYLSQLDataType:YLSQLDataTypeData];
        else
            propertyType = [YLSQLDataTypeConverter stringTypeFromYLSQLDataType:YLSQLDataTypeString];
        
    } else {
        
        if ([type containsString:@"*"])
            propertyType = [YLSQLDataTypeConverter stringTypeFromYLSQLDataType:YLSQLDataTypeString];
        else if ([type containsString:@"d"] || [type containsString:@"D"] || [type containsString:@"f"])
            propertyType = [YLSQLDataTypeConverter stringTypeFromYLSQLDataType:YLSQLDataTypeDouble];
        else
            propertyType = [YLSQLDataTypeConverter stringTypeFromYLSQLDataType:YLSQLDataTypeInteger];
    }
    
    return propertyType;
}

@end

@interface YLShareDBManager()

@property (nonatomic) NSMutableDictionary<NSString *, YLDatabaseManager *> *cache;
@property (nonatomic) dispatch_queue_t internalSerialQueue;

@end

@implementation YLShareDBManager

- (instancetype)init {
    self = [super init];
    
    if (self) {
        _cache = [NSMutableDictionary dictionary];
        _internalSerialQueue = dispatch_queue_create("com.YALO.sharedDBManager.internalSerialQueu", 0);
    }
    
    return self;
}

+ (instancetype)sharedDBManager {
    
    static YLShareDBManager *singletonSharedDBManager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        singletonSharedDBManager = [[YLShareDBManager alloc] init];
    });
    
    return singletonSharedDBManager;
}

+ (YLDatabaseManager *)dbManagerWithPath:(NSString *)path {
    
    return [[self sharedDBManager] dbManagerWithPath:path];
}

- (YLDatabaseManager *)dbManagerWithPath:(NSString *)path {
    
    __block YLDatabaseManager *res;
    
    dispatch_sync(_internalSerialQueue, ^{
        res = [_cache objectForKey:path];
        
        if (!res) {
            res = [[YLDatabaseManager alloc] initWithPath:path];
            [res.dbConnection openDatabaseWithOption:kDatabaseOpenOptionCreateReadwrite];
        }
        
        if (res) {
            [_cache setObject:res forKey:path];
        }
    });
    
    return res;
}

- (void)closeDatabaseWithPath:(NSString *)path {
    
    dispatch_async(_internalSerialQueue, ^{
        
        YLDatabaseManager *database = [_cache objectForKey:path];
        if (database) {
            [database.dbConnection closeDatabase];
        }
    });
}

- (void)closeAllDatabase {
    
    dispatch_async(_internalSerialQueue, ^{
        
        for (YLDatabaseManager *database in _cache.allValues) {
            [database.dbConnection closeDatabase];
        }
    });
}

@end
