//
//  RecordMeetingTests.swift
//  SyncupsTests
//
//  Created by Vanya Mutafchieva on 05/11/2024.
//

import XCTest
@testable import Syncups

@MainActor
class RecordMeetingTests: XCTestCase {
    func testTimer() async {
        var syncup = Syncup.mock
        syncup.duration = .seconds(6)
        let recordModel = RecordMeetingModel(syncup: syncup)
        let expectation = self.expectation(description: "onMeetingFinished")
        recordModel.onMeetingFinished = { _ in expectation.fulfill() }
        
        await recordModel.task()
        self.wait(for: [expectation], timeout: 0)
        XCTAssertEqual(recordModel.secondsElapsed, 6)
        XCTAssertEqual(recordModel.isDismissed, true)
    }
}
