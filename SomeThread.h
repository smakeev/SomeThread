//
//  SomeThread.h
//  SomeThread
//
//  Created by Sergey Makeev on 28/09/2019.
//  Copyright © 2019 SOME projects. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

//=======================================================================================================================
//*	class SomeThread represents a thread.
//
//	works similar to serial queue.
//	Added tasks will be started one after another.
//	But it is guranteed to be launched in the same thread.
//	You can add blocks and invocations.
//	When thread does not have active tasks it sleeps.
//	Also it is possible to run timers on thread.
// 	In case of active timer thread is active even if no other tasks.
//	After all timers invalidates and no more active tasks thread will sleep again.
//
//	Is not a subclass of NSThread, does not provide any start method.
//  But you can easily subclass and add start method providing some block as a start point.
//	Just call stop after the end of the block execution.
//=======================================================================================================================

@class STFuture;
@interface SomeThread : NSObject

/************************************************************************************************************************
*
*	property name.
*
*	Name of the thread. Using for debug. Two or more threads can have the same name.
*	There is no way to get ref. to the thread by it's name.
*
*************************************************************************************************************************/
@property (nonatomic, readonly) NSString * _Nullable name;


/************************************************************************************************************************
*
*	property count.
*
*	Number of tasks in current thread queue. Current task is not counted.
*	Does not contain timers.
*
*************************************************************************************************************************/
@property (nonatomic, readonly) NSInteger count;

/************************************************************************************************************************
*
*	property timersCount.
*
*	Number of timers on current thread.
*
*************************************************************************************************************************/
@property (nonatomic, readonly) NSInteger timersCount;

/************************************************************************************************************************
*
*	+ (instancetype) threadWithName:(NSString *_Nonnull) name
*
*	Create new thread with name and default quality of service
*
*************************************************************************************************************************/
+ (instancetype _Nonnull ) threadWithName:(NSString *_Nonnull) name;

/************************************************************************************************************************
*
*	+ (instancetype) threadWithName:(NSString *_Nonnull) name qualityOfService:(NSQualityOfService) qualityOfService
*
*	Create new thread with name and quality of service
*
*************************************************************************************************************************/
+ (instancetype _Nonnull ) threadWithName:(NSString *_Nonnull) name qualityOfService:(NSQualityOfService) qualityOfService;

// return current thread quality of service
@property (readonly) NSQualityOfService qualityOfService;

// working means thread can handle incoming task.
// It does not mean that thread is active now (working on some task).
// Returns if it can perform selector or not. NO - Thread is stopped
- (BOOL) working;
@property (readonly) BOOL isWorking;

// Is it now active or not.
//	Active - means currantly some action is in progress. NO - thread is sleeping
//	Action could be block, invocation or timer.
- (BOOL) active;
@property (readonly) BOOL isActive;
//Stop the thread.
//After stop thread will ignore tasks adding.
//Note:! Stop does not stop thread immidiatly. After finishing all active blocks it will be stopped.
//	So all tasks added before stop will be executed.
- (void) stop;

//recreate a thread. Old thread will be stopped
//Note it creates new thread inside and stops the old one.
- (void) restart;
- (void) restartWithQualityOfService:(NSQualityOfService) qualityOfService;

//Adding tasks:
/************************************************************************************************************************
*	- (void) performBlock:(void(^ _Nonnull)(void)) block;
*	Add block to tasks.
*************************************************************************************************************************/
- (void) performBlock:(dispatch_block_t _Nonnull ) block NS_SWIFT_NAME(perform(block:));


//- (STFuture*) return

/************************************************************************************************************************
*	- (void) performBlockOnMain:(dispatch_block_t)block
*	Add block to tasks. Block will be started on main thread insted of this thread, but thread will be waiting for it's ending.
*************************************************************************************************************************/
- (void) performBlockOnMain:(dispatch_block_t _Nonnull)block NS_SWIFT_NAME(performOnMain(block:));

/************************************************************************************************************************
*	- (void) performBlock:( void(^ _Nonnull )(void)) block afterDelay:(NSTimeInterval) delay;
*	Add block to tasks. Task will be started after delay.
*	Delay will be started only when the task is active.
*	So if you have many tasks before, delay will be actually longer.
*
*	Calling this method does not encrise counter but it encrises timers counter instead. Technically this is a timer with
*	no repeation.
*
*************************************************************************************************************************/
- (void) performAfterDelay:(NSTimeInterval) delay block:(dispatch_block_t _Nonnull ) block NS_SWIFT_NAME(perform(after:block:));

/************************************************************************************************************************
*	- (void) performBlockSynchroniously:(void(^ _Nonnull)(void)) block;
*	Add block to tasks. Task will be started synchroniously.
*************************************************************************************************************************/
- (void) performBlockSynchroniously:(dispatch_block_t _Nonnull ) block NS_SWIFT_NAME(performSynchroniously(block:));

/************************************************************************************************************************
*	- (void) performInvocation:(NSInvocation*)invocation
*	Add invocation to tasks.
*************************************************************************************************************************/
- (void) performInvocation:(NSInvocation*_Nonnull)invocation;

/************************************************************************************************************************
*	- (void) performInvocation:(NSInvocation*)invocation afterDelay:(NSTimeInterval) delay;
*	Add invocation to tasks. Task will be started after delay.
*	Delay will be started only when the task is active.
*	So if you have many tasks before, delay will be actually longer.
*************************************************************************************************************************/
- (void) performInvocation:(NSInvocation*_Nonnull)invocation afterDelay:(NSTimeInterval) delay;

/************************************************************************************************************************
*	- (void) performInvocationSynchroniously:(NSInvocation*)invocation
*	Add invocation to tasks. Task will be started synchroniously.
*************************************************************************************************************************/
- (void) performInvocationSynchroniously:(NSInvocation*_Nonnull)invocation;

//timers
/************************************************************************************************************************
*	- (NSTimer*)scheduledTimerWithTimeInterval:(NSTimeInterval)ti invocation:(NSInvocation *)invocation repeats:(BOOL)yesOrNo
*	schedule timer for invocation.
*************************************************************************************************************************/
- (NSTimer*_Nonnull)scheduledTimerWithTimeInterval:(NSTimeInterval)ti invocation:(NSInvocation *_Nonnull)invocation repeats:(BOOL)yesOrNo;

/************************************************************************************************************************
*	- (NSTimer*)scheduledTimerWithTimeInterval:(NSTimeInterval)ti target:(id)aTarget selector:(SEL)aSelector userInfo:(nullable id)userInfo repeats:(BOOL)yesOrNo;
*	schedule timer for target with selector.
*************************************************************************************************************************/
- (NSTimer*_Nonnull)scheduledTimerWithTimeInterval:(NSTimeInterval)ti target:(id _Nonnull )aTarget selector:(SEL _Nonnull )aSelector userInfo:(nullable id)userInfo repeats:(BOOL)yesOrNo;

/************************************************************************************************************************
*	- (NSTimer*)scheduledTimerWithTimeInterval:(NSTimeInterval)interval repeats:(BOOL)repeats block:(void (^)(NSTimer *timer))block
*	schedule timer for block.
*************************************************************************************************************************/
- (NSTimer*_Nonnull)scheduledTimerWithTimeInterval:(NSTimeInterval)interval repeats:(BOOL)repeats block:(void (^_Nonnull)(NSTimer * _Nonnull timer))block;

@end


NS_ASSUME_NONNULL_END
