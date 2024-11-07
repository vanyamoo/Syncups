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
        await DependencyValues.withTestValues {
            $0.continuousClock = ImmediateClock()
            $0.speechClient.requestAuthorization = { .denied }
        } assert: { @MainActor in
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
}
