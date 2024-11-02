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
            
            var syncup = Syncup.mock
            let _ = syncup.duration = .seconds(1)
            let _ = syncup.attendees = [.init(id: Attendee.ID(UUID()), name: "John Doe")]
            
            SyncupList(
                model: SyncupListModel(
//                    destination: .detail(
//                        SyncupDetailModel(
//                            //destination: .meeting(Syncup.mock.meetings[0]),
//                            destination: .record(RecordMeetingModel(syncup: syncup)),
//                            syncup: .mock))
                )
            )
            
            
            
//            SyncupList(
//                model: SyncupListModel(
//                    destination: .add(
//                        EditSyncupModel(
//                            focus: .attendee(Syncup.mock.attendees[3].id),
//                            syncup: .mock)),
//                    syncups: [
//                        .mock,
//                    ]
//                )
//            )
        }
    }
}
