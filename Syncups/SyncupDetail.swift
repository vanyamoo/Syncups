//
//  SyncupDetail.swift
//  Syncups
//
//  Created by Vanya Mutafchieva on 28/10/2024.
//

import SwiftUI

class SyncupDetailModel: ObservableObject {
    @Published var syncup: Syncup
    
    init(syncup: Syncup) {
        self.syncup = syncup
    }
}

struct SyncupDetailView: View {
    
    @ObservedObject var model: SyncupDetailModel
    var body: some View {
        List {
            Section {
                Button {
                    //model.startMeetingButtonTapped()
                } label: {
                    Label("Start Meeting", systemImage: "timer")
                        .font(.headline)
                        .foregroundColor(.accentColor)
                }
                HStack {
                    Label("Length", systemImage: "clock")
                    Spacer()
                    Text(model.syncup.duration.formatted(.units()))
                }
                
                HStack {
                    Label("Theme", systemImage: "paintpalette")
                    Spacer()
                    Text(model.syncup.theme.name)
                        .padding(4)
                        .foregroundColor(model.syncup.theme.accentColor)
                        .background(model.syncup.theme.mainColor)
                        .cornerRadius(4)
                }
            } header: {
                Text("Sync-up Info")
            }
            
            if !model.syncup.meetings.isEmpty {
                Section {
                    ForEach(model.syncup.meetings) { meeting in
                        Button {
                            //model.meetingTapped(meeting)
                        } label: {
                            HStack {
                                Image(systemName: "calendar")
                                Text(meeting.date, style: .date)
                                Text(meeting.date, style: .time)
                            }
                        }
                    }
                    .onDelete { indices in
                        //model.deleteMeetings(atOffsets: indices)
                    }
                } header: {
                    Text("Past meetings")
                }
            }
            
            Section {
                ForEach(model.syncup.attendees) { attendee in
                    Label(attendee.name, systemImage: "person")
                }
            } header: {
                Text("Attendees")
            }
            
            Section {
                Button("Delete") {
                    //model.deleteButtonTapped()
                }
                .foregroundColor(.red)
                .frame(maxWidth: .infinity)
            }
        }
    }
}

#Preview {
    SyncupDetailView(model: SyncupDetailModel(syncup: .mock))
}
