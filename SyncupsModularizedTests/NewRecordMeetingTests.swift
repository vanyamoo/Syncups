//
//  NewRecordMeetingTests.swift
//  SyncupsTests
//
//  Created by Vanya Mutafchieva on 06/11/2024.
//
import Clocks
import Dependencies
import XCTest
@testable import Syncups
//import Speech
//@preconcurrency import Speech


class NewRecordMeetingTests: XCTestCase {
    
    func testTimer() async {
        await DependencyValues.withTestValues { // The Dependencies framework comes with a helper that allows you to override tests for a well-defined scope. It’s called withTestValues, and it’s defined as a static method on DependencyValues, which is the global collection of dependencies registered in the application. It takes two trailing closures
            $0.continuousClock = ImmediateClock() // The first is handed a mutable copy of the current dependencies and you are free to mutate it however you feel. This is the place where it is appropriate to override any dependencies you think your feature makes use of in the user flow you are testing, such as the clock
            $0.speechClient.requestAuthorization = { .denied }
        } assert: { @MainActor in  // Then you put all your assertion code in the last trailing closure
            var syncup = Syncup.mock
            syncup.duration = .seconds(6)
            let recordModel = RecordMeetingModel(
                //clock: ImmediateClock(),
                syncup: syncup)
            let expectation = self.expectation(description: "onMeetingFinished")
            recordModel.onMeetingFinished = { _ in expectation.fulfill() }
            
            await recordModel.task()
            await fulfillment(of: [expectation], timeout: 0) //self.wait(for: [expectation], timeout: 0)
            XCTAssertEqual(recordModel.secondsElapsed, 6)
            //XCTAssertEqual(recordModel.isDismissed, true)
        }
    }
    
    // Thanks to some improvements made to swift-dependencies, the above test can now be written like so (Note that only the model needs to be constructed in the scope of withDependencies. All of the assertions can happen outside):
//    var standup = Standup.mock
//    standup.duration = .seconds(6)
//    let recordModel = withDependencies {
//      $0.continuousClock = ImmediateClock()
//    } operation: {
//      RecordMeetingModel(standup: standup)
//    }
//    let expectation = self.expectation(
//      description: "onMeetingFinished"
//    )
//    recordModel.onMeetingFinished = { _ in
//      expectation.fulfill()
//    }
//    await recordModel.task()
//    self.wait(for: [expectation], timeout: 0)
//    XCTAssertEqual(recordModel.secondsElapsed, 6)
//    XCTAssertEqual(recordModel.dismiss, true)

/*
    DependencyValues.withTestValues { inout DependencyValues in
      //code
    } assert: {
      //code
    }
    
    // is now:
    
    withDependencies { inout DependencyValues in
      //code
    } operation: {
      //code
    }
*/
}
