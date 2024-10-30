//
//  SyncupDetail.swift
//  Syncups
//
//  Created by Vanya Mutafchieva on 28/10/2024.
//

import SwiftUINavigation
import SwiftUI

class SyncupDetailModel: ObservableObject, Identifiable {
    @Published var destination: Destination?
    @Published var syncup: Syncup
    
    @CasePathable
    enum Destination {
        case meeting(Meeting) // we use a little plain struct Meeting for the associated value because the historical meeting View doesn't need a full-blown @ObservableObject
    }
    
    init(destination: Destination? = nil, syncup: Syncup) { // we want to be able to instantiate the model with the destination (because this allows deep linking)
        self.destination = destination
        self.syncup = syncup
    }
    
    func deleteMeetings(atOffsets indices: IndexSet) {
        syncup.meetings.remove(atOffsets: indices)
    }
    
    func meetingTapped(_ meeting: Meeting) {
        destination = .meeting(meeting)
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
                            model.meetingTapped(meeting)
                        } label: {
                            HStack {
                                Image(systemName: "calendar")
                                Text(meeting.date, style: .date)
                                Text(meeting.date, style: .time)
                            }
                        }
                    }
                    .onDelete { indices in
                        model.deleteMeetings(atOffsets: indices)
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
        .navigationTitle(model.syncup.title)
        .toolbar {
            Button("Edit") {
                
            }
        }
//        .navigationDestination(item: $model.destination.meeting) { meeting in
//            MeetingView(meeting: meeting, syncup: model.syncup)
//        }
        .sheet(item: $model.destination.meeting) { meeting in
            MeetingView(meeting: meeting, syncup: model.syncup)
        }
    }
}

struct MeetingView: View {
  let meeting: Meeting
  let syncup: Syncup

  var body: some View {
    ScrollView {
      VStack(alignment: .leading) {
        Divider()
          .padding(.bottom)
        Text("Attendees")
          .font(.headline)
        ForEach(self.syncup.attendees) { attendee in
          Text(attendee.name)
        }
        Text("Transcript")
          .font(.headline)
          .padding(.top)
        Text(self.meeting.transcript)
      }
    }
    .navigationTitle(Text(self.meeting.date, style: .date))
    .padding()
  }
}

#Preview {
    //SyncupDetailView(model: SyncupDetailModel(destination: .meeting(Syncup.mock.meetings[0]), syncup: .mock))
    NavigationStack {
        SyncupDetailView(model: SyncupDetailModel(syncup: .mock))
    }
}
