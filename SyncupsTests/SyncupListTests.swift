//
//  SyncupListTests.swift
//  SyncupsTests
//
//  Created by Vanya Mutafchieva on 05/11/2024.
//

import XCTest

@testable import Syncups

@MainActor
class SyncupListTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        try? FileManager.default.removeItem(at: .documentsDirectory.appending(component: "sync-ups.json"))
    }
    
    func testPersistence() async throws {
        let listModel = SyncupListModel()
        
        XCTAssertEqual(listModel.syncups.count, 0)
        
        listModel.addSyncupButtonTapped()
        listModel.confirmAddSyncupButtonTapped()
        XCTAssertEqual(listModel.syncups.count, 1)
        
        try await Task.sleep(for: .milliseconds(1_100))
        
        let nextLaunchListModel = SyncupListModel()
        XCTAssertEqual(nextLaunchListModel.syncups.count, 1)
    }
}

