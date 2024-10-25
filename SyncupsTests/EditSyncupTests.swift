//
//  EditSyncupTests.swift
//  Syncups
//
//  Created by Vanya Mutafchieva on 25/10/2024.
//

import XCTest
@testable import Syncups

class EditSyncupTests: XCTestCase {
    
    func testDeletion() {
        let model = EditSyncupModel(syncup: Syncup(id: Syncup.ID(UUID()), attendees: [
            Attendee(id: Attendee.ID(UUID()), name: "Blob"),
            Attendee(id: Attendee.ID(UUID()), name: "Blob Jr")
        ]))
        
        model.deleteAttendees(atOffsets: [1])
        
        XCTAssertEqual(model.syncup.attendees.count, 1)
        XCTAssertEqual(model.syncup.attendees[0].name, "Blob")
        
        XCTAssertEqual(model.focus, .attendee(model.syncup.attendees[0].id))
    }
    
    func testAdd() {
        let model = EditSyncupModel(syncup: Syncup(id: Syncup.ID(UUID())))
        
        XCTAssertEqual(model.syncup.attendees.count, 1)
        XCTAssertEqual(model.focus, .title)
        model.addAttendeeButtonTapped()
        
        XCTAssertEqual(model.syncup.attendees.count, 2)
        XCTAssertEqual(model.focus, .attendee(model.syncup.attendees[1].id))
    }
}
