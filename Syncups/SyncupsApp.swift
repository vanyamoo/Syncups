//
//  SyncupsApp.swift
//  Syncups
//
//  Created by Vanya Mutafchieva on 23/10/2024.
//

import SwiftUI

@main
struct SyncupsApp: App {
    var body: some Scene {
        WindowGroup {
            
//            SyncupList(
//                model: SyncupListModel(
//                    destination: .detail(
//                        SyncupDetailModel(
//                            destination: .meeting(Syncup.mock.meetings[0]),
//                            syncup: .mock)),
//                    syncups: [.mock, .engineeringMock, .designMock]))
            
            SyncupList(
                model: SyncupListModel(
                    destination: .add(
                        EditSyncupModel(
                            focus: .attendee(Syncup.mock.attendees[3].id),
                            syncup: .mock)),
                    syncups: [
                        .mock,
                    ]
                )
            )
        }
    }
}
