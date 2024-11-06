//
//  SyncupListTests.swift
//  SyncupsTests
//
//  Created by Vanya Mutafchieva on 05/11/2024.
//

import Dependencies
import XCTest

@testable import Syncups

@MainActor
class SyncupListTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        try? FileManager.default.removeItem(at: .documentsDirectory.appending(component: "sync-ups.json"))
    }
    
    func testPersistence() async throws {
        
        // we need to control the mainQueue dependency
        let mainQueue = DispatchQueue.test
        DependencyValues.withTestValues {
            $0.mainQueue = mainQueue.eraseToAnyScheduler()
        } assert: {
            let listModel = SyncupListModel()
            
            XCTAssertEqual(listModel.syncups.count, 0)
            
            listModel.addSyncupButtonTapped()
            listModel.confirmAddSyncupButtonTapped()
            XCTAssertEqual(listModel.syncups.count, 1)
            
            mainQueue.run() // try await Task.sleep(for: .milliseconds(1_100))
            
            let nextLaunchListModel = SyncupListModel()
            XCTAssertEqual(nextLaunchListModel.syncups.count, 1)
        }
    }
}

