//
//  STFuture.m
//  SomeThread
//
//  Created by Sergey Makeev on 14.10.2019.
//  Copyright © 2019 SOME projects. All rights reserved.
//

#import "STFuture.h"

@interface STFuture()

@property (atomic, strong, nullable) id       result;
@property (atomic, strong, nullable) NSError* error;
@property (atomic, assign)           BOOL     resolved;

@property (nonatomic)                 dispatch_queue_t                  queue;
@property (nonatomic, copy, nullable) void (^blockNext)        (id _Nullable);
@property (nonatomic, copy, nullable) void (^blockCatch)  (NSError* _Nullable);
@property (nonatomic, copy, nullable) void (^blockFinally)(void);

@end

@interface STFuture (ForFriendsOnly)

- (void) performActionWithResult:(id _Nullable)        result;
- (void) performActionWithError: (NSError* _Nullable ) error;

@end

@implementation STFuture

- (instancetype) initWithQueue:(dispatch_queue_t) queue {
	self = [super init];
	if (self) {
		self.queue = queue;
	}
	
	return self;
}

- (STFuture*) next:(void(^__nonnull)(id _Nullable)) actionBLock {
	self.blockNext = actionBLock;
	return self;
}

- (STFuture*) catch:(void(^__nonnull)(NSError* _Nullable )) exceptionBlock {
	self.blockCatch = exceptionBlock;
	return self;
}

- (STFuture*) finally:(void(^__nonnull)(void)) finallyBlock {
	self.blockFinally = finallyBlock;
	return self;
}

- (void) performAction:(id _Nullable)result {
	self.result   = result;
	self.resolved = YES;
	
	if (self.blockNext) {
		self.blockNext(result);
	}
	if (self.blockFinally) {
		self.blockFinally();
	}
}

- (void) performActionWithResult:(id _Nullable)result {
	if (self.queue) {
		dispatch_async(self.queue, ^{
			[self performAction: result];
		});
	} else {
		dispatch_async(dispatch_get_main_queue(), ^{
			[self performAction: result];
		});
	}
}

- (void) performError:(NSError* _Nullable)error {
	self.error    = error;
	self.resolved = YES;
	
	if (self.blockCatch) {
		self.blockCatch(error);
	}
	if (self.blockFinally) {
		self.blockFinally();
	}
}

- (void) performActionWithError: (NSError* _Nullable ) error {
	if (self.queue) {
		dispatch_async(self.queue, ^{
			[self performError: error];
		});
	} else {
		dispatch_async(dispatch_get_main_queue(), ^{
			[self performError: error];
		});
	}
}

@end
