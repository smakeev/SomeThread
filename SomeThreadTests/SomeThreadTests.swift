//
//  SomeThreadTests.swift
//  SomeThreadTests
//
//  Created by Sergey Makeev on 06/10/2019.
//  Copyright © 2019 SOME projects. All rights reserved.
//

import XCTest
import SomeThread
class SomeThreadTests: XCTestCase {
	
	override func setUp() {
		// Put setup code here. This method is called before the invocation of each test method in the class.
	}
	
	override func tearDown() {
		// Put teardown code here. This method is called after the invocation of each test method in the class.
	}
	
	func testNameExample() {
		let thread = SomeThread(name: "Test1")
		XCTAssert(thread.name == "Test1")

		let thread1 = SomeThread(name: "Test2", qualityOfService: QualityOfService.background)
		XCTAssert(thread1.name == "Test2")
		XCTAssert(thread1.qualityOfService == QualityOfService.background)

		XCTAssert(thread.working() == true)
		XCTAssert(thread.isWorking == true)
		XCTAssert(thread.active() == false)
		XCTAssert(thread.isActive == false)
	}

	func testStopAndRestart() {
		let thread1 = SomeThread(name: "Test2", qualityOfService: QualityOfService.background)
		XCTAssert(thread1.qualityOfService == QualityOfService.background)
		XCTAssert(thread1.isWorking == true)
		thread1.stop()
		XCTAssert(thread1.isWorking == false)
		thread1.restart()
		XCTAssert(thread1.isWorking == true)
		thread1.restart(with: QualityOfService.userInteractive)
		XCTAssert(thread1.qualityOfService == QualityOfService.userInteractive)
	}

	func testPerformBlock() {
		let thread1 = SomeThread(name: "Test")
		var testFinished = false
		var buffer = [Int]()
		thread1.perform {
			sleep(2)
			for i in 1...5 {
				print(i)
				buffer.append(i)
			}
		}
		thread1.perform {
			sleep(2)
			for i in 1000...1005 {
				print(i)
				buffer.append(i)
			}
		}
		thread1.perform {
			sleep(2)
			testFinished = true
		}
		sleep(2) //to give thread a time to start
		while(thread1.isActive) {

		}
		XCTAssert(testFinished == true)
		XCTAssert(thread1.isActive == false)
		XCTAssert(thread1.isWorking == true)
		XCTAssert(buffer == [1, 2 ,3 ,4 ,5, 1000, 1001, 1002, 1003, 1004, 1005])
	}

	let thread2 = SomeThread(name: "Test2")
	var threadToTestOnMain: SomeThread? = nil
	var codeHasBeenCalled = false
	func testPesrformBlockOnMain() {
		threadToTestOnMain = SomeThread(name: "Test")
		threadToTestOnMain?.perform {
			sleep(5)
		}
		DispatchQueue.global().async {
			self.threadToTestOnMain?.performOnMain {
				XCTAssert(Thread.current.isMainThread)
				self.codeHasBeenCalled = true
			}
		}

		thread2.perform {
			sleep(10) //wait for thread1 be finished
			XCTAssert(self.codeHasBeenCalled)
		}
	}

	var threadToTestAfterDelay: SomeThread? = nil
	let thread3 = SomeThread(name: "Test3")
	var codeInDelayTestHasBeenCalled = false
	func testPerformBlockAfterDelay() {
		threadToTestAfterDelay = SomeThread(name: "afterDelay")
		let current = Date()
		threadToTestAfterDelay?.perform(after:20) {
			self.codeInDelayTestHasBeenCalled = true
			let current2 = Date()
			XCTAssert(current2.timeIntervalSince1970 - current.timeIntervalSince1970 >= 20)
		}

		thread3.perform {
			sleep(30) //wait for thread1 be finished
			XCTAssert(self.codeInDelayTestHasBeenCalled)
		}
	}

	func testPerformSync() {
		let thread = SomeThread(name: "SYNC")
		var finished = false
		thread.performSynchroniously {
			sleep(5)
			XCTAssert(!Thread.current.isMainThread)
			finished = true
		}
		sleep(2)
		XCTAssert(finished)
	}

	
	func testTimer() {
		let thread = SomeThread(name: "ForTimer")
		var iteration = 0
		var finished = false
		thread.scheduledTimer(withTimeInterval: 0.5, repeats: true) { timer in
			XCTAssert(!Thread.current.isMainThread)
			iteration += 1
			
			if iteration > 3 {
				timer.invalidate()
				finished = true
			}
		}
		
		sleep(2) //to let thread start working
		while(thread.isActive) {
		
		}
		sleep(2)
		XCTAssert(finished)
		XCTAssert(iteration == 4)
	}
	
	func testCount() {
		let thread = SomeThread(name: "CountTest")
		XCTAssert(thread.count == 0)
		thread.perform {
			sleep(5)
		}
		XCTAssert(thread.count == 1)
		thread.perform {
			sleep(5)
		}
		XCTAssert(thread.count == 2)
		sleep(5)
		XCTAssert(thread.count == 1)
		sleep(15)
		XCTAssert(thread.count == 0)
	}
	
	func testTimersCount() {
		let thread = SomeThread(name: "TimersCountTest")
		XCTAssert(thread.timersCount == 0)
		var iteration = 0
		var finished = false
		thread.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
			XCTAssert(!Thread.current.isMainThread)
			iteration += 1
			
			if iteration > 2 {
				timer.invalidate()
				finished = true
			}
		}
		sleep(1) //to let thread start working
		XCTAssert(thread.timersCount == 1)
		while(thread.isActive && thread.timersCount == 1) {
			XCTAssert(thread.timersCount == 1 || thread.timersCount == 0)
		}
		sleep(2)
		XCTAssert(finished)
		XCTAssert(thread.timersCount == 0)
	}
	
}
