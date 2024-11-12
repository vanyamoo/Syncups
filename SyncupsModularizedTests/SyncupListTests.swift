//
//  SyncupListTests.swift
//  SyncupsTests
//
//  Created by Vanya Mutafchieva on 05/11/2024.
//

import CustomDump
import Dependencies
import XCTest

@testable import Syncups

@MainActor
class SyncupListTests: XCTestCase {
    
//    override func setUp() {
//        super.setUp()
//        try? FileManager.default.removeItem(at: .documentsDirectory.appending(component: "sync-ups.json"))
//    }
    
    func testPersistence() async throws {
        let mainQueue = DispatchQueue.test
        DependencyValues.withTestValues { // we need to control the mainQueue dependency
            $0.dataManager = .mock()
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
    
    func testEdit() throws {
        let mainQueue = DispatchQueue.test
        try DependencyValues.withTestValues {
            $0.dataManager = .mock(
                initialData: try JSONEncoder().encode([Syncup.mock])
            )
            $0.mainQueue = mainQueue.eraseToAnyScheduler()
        } assert: {
            let listModel = SyncupListModel()
            
            // the next 3 lines (emulating user actions) pass, but it'll be real pain to emulate user actions like this (adding syncups to the listModel) every time we want to test some special case of a user flow. So we need to start controlling our dependency on loading and saving data to disk
            // listModel.addSyncupButtonTapped() // 1. we don't need these any more now that we control our dependency
            // listModel.confirmAddSyncupButtonTapped()
            XCTAssertEqual(listModel.syncups.count, 1)
            
            // 2. now finally we can start emulating user actions
            listModel.syncupTapped(syncup: listModel.syncups[0])
            guard case let .some(.detail(detailModel)) = listModel.destination
            else {
                XCTFail()
                return
            }
            XCTAssertEqual(detailModel.syncup, listModel.syncups[0])
            
            detailModel.editButtonTapped()
            guard case let .some(.edit(editModel)) = detailModel.destination
            else {
                XCTFail()
                return
            }
            expectNoDifference(editModel.syncup, detailModel.syncup) // XCTAssertEqual(editModel.syncup, detailModel.syncup)
            
            editModel.syncup.title = "Product"
            detailModel.doneEdittingButtonTapped()
            
            XCTAssertNil(detailModel.destination)
            XCTAssertEqual(detailModel.syncup.title, "Product")
            
            listModel.destination = nil
            
            XCTAssertEqual(listModel.syncups[0].title, "Product")
        }
    }
}

