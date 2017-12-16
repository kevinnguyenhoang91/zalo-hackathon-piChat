//
//  YLDatabaseQueue.m
//  YALO
//
//  Created by VanDao on 8/12/16.
//  Copyright © 2016 admin. All rights reserved.
//

#import "YLDatabaseQueue.h"
#import <objc/runtime.h>

#define kPropertyName @"Name"
#define kPropertyType @"Type"
#define kPropertyTypeNumber @"TypeNumber"
#define kPropertyTypeString @"TypeString"

@interface YLDatabaseQueue ()

@end

@implementation YLDatabaseQueue

- (instancetype)initWithPath:(NSString *)databasePath {
    
    return [self initWithPath:databasePath underlyingQueue:nil];
}

- (instancetype)initWithPath:(NSString *)databasePath underlyingQueue:(dispatch_queue_t)queue {
    self = [super init];
    
    if (self) {
        _dbConnection = [YLSQLDatabase databaseWithPath:databasePath];
        if ([_dbConnection openDatabaseWithOption:kDatabaseOpenOptionReadwrite])
            return nil;
        
        _operationQueue = [[NSOperationQueue alloc] init];
        _operationQueue.qualityOfService = NSQualityOfServiceDefault;
        _operationQueue.maxConcurrentOperationCount = 1;
        _operationQueue.name = @"Serial queue";
        _underlyingQueue = queue ?: dispatch_queue_create("com.YLDatabaseQueue.underlyingQueue", 0);
        _operationQueue.underlyingQueue = _underlyingQueue;
    }
    
    return self;
}

+ (instancetype)databaseWithPath:(NSString *)databasePath {
    
    return [[self alloc] initWithPath:databasePath];
}

+ (instancetype)databaseWithPath:(NSString *)databasePath underlyingQueue:(dispatch_queue_t)queue {

    return [[self alloc] initWithPath:databasePath underlyingQueue:queue];
}

- (void)openDatabaseWithOption:(DatabaseOpenOption)option {
    
    [_operationQueue addOperation:[NSBlockOperation blockOperationWithBlock:^{
        [_dbConnection openDatabaseWithOption:option];
    }]];
}

- (void)openDatabaseWithOption:(DatabaseOpenOption)option completionHandler:(void(^)(NSError *))callbackBlock onQueue:(dispatch_queue_t)callBackQueue {

    [_operationQueue addOperation:[NSBlockOperation blockOperationWithBlock:^{
        [_dbConnection openDatabaseWithOption:option completionHandler:callbackBlock onQueue:callBackQueue];
    }]];
}

- (void)closeDatabase {
    
    [_operationQueue addOperation:[NSBlockOperation blockOperationWithBlock:^{
        [_dbConnection closeDatabase];
    }]];
}

- (void)closeDatabaseWithCompletionHandler:(void(^)(NSError *))callbackBlock onQueue:(dispatch_queue_t)callBackQueue {
    
    [_operationQueue addOperation:[NSBlockOperation blockOperationWithBlock:^{
        [_dbConnection closeDatabaseWithCompletionHandler:callbackBlock onQueue:callBackQueue];
    }]];
}


- (void)executeQueryCommand:(YLSQLCommand *)sqlCommand withPriority:(NSOperationQueuePriority)priority completionHandler:(ExecutedCallbackBlock)callbackBlock onQueue:(dispatch_queue_t)callbackQueue {
    
    NSBlockOperation *operation = [NSBlockOperation blockOperationWithBlock:^{
        [_dbConnection executeQueryCommand:sqlCommand withCompletionHandler:callbackBlock onQueue:callbackQueue];
    }];
    operation.queuePriority = priority;

    [_operationQueue addOperation:operation];
}

- (void)executeCommand:(YLSQLCommand *)sqlCommand withPriority:(NSOperationQueuePriority)priority completionHandler:(ExecuteCommandCallbackBlock)callbackBlock onQueue:(dispatch_queue_t)callbackQueue {
    
    NSBlockOperation *operation = [NSBlockOperation blockOperationWithBlock:^{
        [_dbConnection executeCommand:sqlCommand withCompletionHandler:callbackBlock onQueue:callbackQueue];
    }];
    operation.queuePriority = priority;
    
    [_operationQueue addOperation:operation];
}

- (void)beginTransactionWithPriority:(NSOperationQueuePriority)priority {
    
    NSBlockOperation *operation = [NSBlockOperation blockOperationWithBlock:^{
        [_dbConnection beginTransaction];
    }];
    operation.queuePriority = priority;
    
    [_operationQueue addOperation:operation];
}

- (void)commitTransactionWithPriority:(NSOperationQueuePriority)priority {
    NSBlockOperation *operation = [NSBlockOperation blockOperationWithBlock:^{
        [_dbConnection commitTransaction];
    }];
    operation.queuePriority = priority;
    
    [_operationQueue addOperation:operation];
}

- (void)rollbackTransactionWithPriority:(NSOperationQueuePriority)priority {
    
    NSBlockOperation *operation = [NSBlockOperation blockOperationWithBlock:^{
        [_dbConnection rollbackTransaction];
    }];
    operation.queuePriority = priority;
    
    [_operationQueue addOperation:operation];
}


- (void)executeInTransaction:(NSArray *)commandList withPriority:(NSOperationQueuePriority)priority completionBlock:(void(^)(NSError *error))callbackBlock onQueue:(dispatch_queue_t)callbackQueue {
    
    NSBlockOperation *operation = [NSBlockOperation blockOperationWithBlock:^{
        [_dbConnection beginTransaction];
        
        int msgReceive = 0;
        for (YLSQLCommand *command in commandList) {
            msgReceive = [_dbConnection executeCommand:command];
            
            if (msgReceive != SQLITE_OK) {
                msgReceive = [_dbConnection rollbackTransaction];
                break;
            }
        }
        
        [_dbConnection commitTransaction];
        
        if (callbackBlock) {
            NSError *err = (msgReceive != SQLITE_OK) ? [NSError errorWithDomain:@"com.DatabaseQueue.exectueTransaction" code:msgReceive userInfo:nil] : nil;
            
            dispatch_queue_t queue = callbackQueue ?: dispatch_get_main_queue();
            dispatch_async(queue, ^{
                callbackBlock(err);
            });
        }
    }];
    operation.queuePriority = priority;
    
    [_operationQueue addOperation:operation];
}


@end
