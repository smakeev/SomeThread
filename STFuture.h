//
//  STFuture.h
//  SomeThread
//
//  Created by Sergey Makeev on 14.10.2019.
//  Copyright © 2019 SOME projects. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface STFuture : NSObject

@property (atomic, readonly, nullable) id       result;
@property (atomic, readonly, nullable) NSError* error;
@property (atomic, readonly)           BOOL     resolved;


- (instancetype) initWithQueue:(dispatch_queue_t) queue;

- (STFuture*) next:(void(^__nonnull)(id _Nullable)) actionBLock;
- (STFuture*) catch:(void(^__nonnull)(NSError* _Nullable )) exceptionBlock;
- (STFuture*) finally:(void(^__nonnull)(void)) finallyBlock;

@end

NS_ASSUME_NONNULL_END
