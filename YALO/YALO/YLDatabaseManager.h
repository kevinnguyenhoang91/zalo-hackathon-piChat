//
//  YLORMStorageManager.h
//  YALO
//
//  Created by VanDao on 8/9/16.
//  Copyright © 2016 admin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YLBaseModel.h"
#import "YLExpression.h"
#import "YLSortDescription.h"
#import "YLSQLDatabase.h"

@class YLShareDBManager;

@interface YLDatabaseManager : NSObject

@property (readonly) YLSQLDatabase *dbConnection;

- (instancetype)initWithPath:(NSString *)path;

/**
 *  Create a table for class in database if not exist
 *
 *  @param className         The name of class
 *  @param propertyNameArray List of property name of class is a primary key of table in database
 */
- (void)createTableForClass:(Class)className withPrimaryKey:(NSArray *)propertyNameArray;

/**
 *  Fetch and return all object for class in database
 *
 *  @param className The name of class
 *
 *  @return List of dictionary
 */
- (NSArray *)fetchAllObjectForClass:(Class)className;

/**
 *  Fetch and return all object with expression match from database and return to list of dictionary
 *
 *  @param expression The logical expression to fetch object
 *
 *  @return The list of dictionary that contain property values of object
 */
- (NSArray *)fetchObjectForClass:(Class)className withMatching:(YLExpression *)expression;

/**
 *  Fetch and return all object with expression match, sort description from database and return to list of dictionary
 *
 *  @param expression      The logical expression to fetch object
 *  @param sortDescription The sort description that descript the field name will be sort
 *
 *  @return Th
 */
- (NSArray *)fetchObjectForClass:(Class)className withMatching:(YLExpression *)expression sortDesciption:(NSArray<YLSortDescription *>*)sortDescription;

/**
 *  Save all objects in array to database, class type of object can different with other object in array
 *
 *  @param objects List of object want to save
 *
 *  @return YES if save successfully, otherwise, return NO
 */
- (BOOL)saveObjects:(NSArray *)objects;

/**
 *  Remove all object in table with specifier class
 *
 *  @param className The class model of table in database
 *
 *  @return YES if remove finish successfully, otherwise, return NO
 */
- (BOOL)deleteAllObjectsForClass:(Class)className;

@end

@interface YLShareDBManager : NSObject

+ (YLDatabaseManager *)dbManagerWithPath:(NSString *)path;

- (void)closeDatabaseWithPath:(NSString *)path;

- (void)closeAllDatabase;

@end
