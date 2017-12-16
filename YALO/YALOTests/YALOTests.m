//
//  YALOTests.m
//  YALOTests
//
//  Created by BaoNQ on 7/28/16.
//  Copyright © 2016 admin. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "YLSQLDatabase.h"

@interface YALOTests : XCTestCase

@property YLSQLDatabase *database;
@property NSString *sql;

@end

@implementation YALOTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    
    _database = [YLSQLDatabase databaseWithPath:@"TestDB"];
    [_database openDatabaseWithOption:kDatabaseOpenOptionCreateReadwrite];
}

- (void)testCreateTable {
    _sql = @"CREATE TABLE COMPANY("  \
    "ID PRIMARY KEY     NOT NULL," \
    "NAME           BLOB    NOT NULL," \
    "AGE            INT     NOT NULL," \
    "ADDRESS        CHARACTER(200)," \
    "SALARY         REAL );";
    
    YLSQLCommand *command = [YLSQLCommand SQLCommandWithFormat:_sql, nil];
    XCTAssert([_database executeCommand:command], @"Cant not create table");
}

- (void)testInsertToTable {
    
    // Create COMPANY table
    _sql = @"CREATE TABLE COMPANY("  \
    "ID PRIMARY KEY     NOT NULL," \
    "NAME           BLOB    NOT NULL," \
    "AGE            INT     NOT NULL," \
    "ADDRESS        CHARACTER(200)," \
    "SALARY         REAL );";
    
    YLSQLCommand *command = [YLSQLCommand SQLCommandWithFormat:_sql, nil];
    [_database executeCommand:command];
    
    // Insert
    _sql = @"INSERT INTO COMPANY (ID,NAME,AGE,ADDRESS,SALARY) "  \
    "VALUES (1, 'sif', 32, 'California', 203000.00 ), " \
    "(2, 'Allen', 25, 'Texas', 150300.00 ), "     \
    "(3, 'Teddy', 23, 'Norway', 200300.00 )," \
    "(4, 'Mark', 25, 'Rich-Mond ', 650030.00 );";
    
    command = [YLSQLCommand SQLCommandWithFormat:_sql, nil];
    XCTAssert([_database executeCommand:command], @"Cannot insert to table");
}

- (void)testQueryFromTable {
    // Create COMPANY table
    _sql = @"CREATE TABLE COMPANY("  \
    "ID PRIMARY KEY     NOT NULL," \
    "NAME           BLOB    NOT NULL," \
    "AGE            INT     NOT NULL," \
    "ADDRESS        CHARACTER(200)," \
    "SALARY         REAL );";
    
    YLSQLCommand *command = [YLSQLCommand SQLCommandWithFormat:_sql, nil];
    [_database executeCommand:command];
    
    // Insert
    _sql = @"INSERT INTO COMPANY (ID,NAME,AGE,ADDRESS,SALARY) "  \
    "VALUES (1, 'sif', 32, 'California', 203000.00 ), " \
    "(2, 'Allen', 25, 'Texas', 150300.00 ), "     \
    "(3, 'Teddy', 23, 'Norway', 200300.00 )," \
    "(4, 'Mark', 25, 'Rich-Mond ', 650030.00 );";
    
    command = [YLSQLCommand SQLCommandWithFormat:_sql, nil];
    [_database executeCommand:command];
    
    command = [YLSQLCommand SQLCommandWithFormat:@"SELECT * FROM COMPANY", nil];
    YLSQLResult *res = [_database executeQueryCommand:command];
    
    XCTAssert(res != nil, @"Cannt query from table");
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
