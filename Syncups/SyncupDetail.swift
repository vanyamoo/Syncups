//
//  SyncupDetail.swift
//  Syncups
//
//  Created by Vanya Mutafchieva on 28/10/2024.
//

import SwiftUINavigation
import SwiftUI
import XCTestDynamicOverlay

class SyncupDetailModel: ObservableObject, Identifiable {
    @Published var destination: Destination?
    @Published var syncup: Syncup
    
    var onConfirmDeletion: () -> Void = unimplemented("SyncupDetailModel.onConfirmDeletion")
    
    @CasePathable
    enum Destination {
        case alert(AlertState<AlertAction>)
        case edit(EditSyncupModel)
        case meeting(Meeting) // we use a little plain struct Meeting for the associated value because the historical meeting View doesn't need a full-blown @ObservableObject
    }
    
    enum AlertAction {
        case confirmDeletion
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
    
    func deleteButtonTapped() {
        destination = .alert(.deleteSyncup)
    }
    
    func alertButtonTapped(_ action: AlertAction) {
        switch action {
        case .confirmDeletion:
            onConfirmDeletion()
        }
    }
    
    func editButtonTapped() {
        destination = .edit(EditSyncupModel(syncup: syncup))
    }
    
    func doneEdittingButtonTapped() {
        guard case let .edit(editModel) = destination else { return }
        
        syncup = editModel.syncup
        destination = nil
    }
    
    func cancelEditButtonTapped() {
        destination = nil
    }
}

struct SyncupDetailView: View {
    
    @ObservedObject var model: SyncupDetailModel
    
    //let onConfirnDeletion: () -> Void
    
    var body: some View {
        List {
            syncupInfo
            
            pastMeetings
            
            attendees
            
            delete
        }
        .navigationTitle(model.syncup.title)
        .toolbar {
            Button("Edit") {
                model.editButtonTapped()
            }
        }
        .navigationDestination(item: $model.destination.meeting) { $meeting in
            NavigationStack {
                MeetingView(meeting: meeting, syncup: model.syncup)
            }
        }
//        .sheet(item: $model.destination.meeting) { meeting in
//            MeetingView(meeting: meeting, syncup: model.syncup)
//        }
        .alert($model.destination.alert) { action in
            guard let action else { return }
            model.alertButtonTapped(action) //await model.alertButtonTapped(action)
        }
        .sheet(item: $model.destination.edit) { $editModel in
            NavigationStack {
                EditSyncupView(model: editModel)
                    .navigationTitle(model.syncup.title)
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Cancel") {
                                model.cancelEditButtonTapped()
                            }
                        }
                        ToolbarItem(placement: .confirmationAction) {
                            Button("Done") {
                                model.doneEdittingButtonTapped()
                            }
                        }
                    }
            }
        }
    }
    
    private var syncupInfo: some View {
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
    }
    
    @ViewBuilder
    private var pastMeetings: some View {
        if !model.syncup.meetings.isEmpty {
            Section {
                ForEach(model.syncup.meetings) { meeting in
                    Button { // NavigationLink(destination: MeetingView(meeting: meeting, syncup: model.syncup)) {
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
    }
    
    private var attendees: some View {
        Section {
            ForEach(model.syncup.attendees) { attendee in
                Label(attendee.name, systemImage: "person")
            }
        } header: {
            Text("Attendees")
        }
    }
    
    private var delete: some View {
        Section {
            Button("Delete") {
                model.deleteButtonTapped()
            }
            .foregroundColor(.red)
            .frame(maxWidth: .infinity)
        }
    }
}

extension AlertState where Action == SyncupDetailModel.AlertAction {
    static let deleteSyncup = Self {
        TextState("Delete?")
    } actions: {
        ButtonState(role: .destructive, action: .confirmDeletion) {
            TextState("Yes")
        }
        ButtonState(role: .cancel) {
            TextState("Nevermind")
        }
    } message: {
        TextState("Are you sure you want to delete this sync-up?")
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
    NavigationStack {
        SyncupDetailView(model: SyncupDetailModel(destination: .meeting(Syncup.mock.meetings[0]), syncup: .mock))
    }
    
//    NavigationStack {
//        SyncupDetailView(model: SyncupDetailModel(destination:
//            .alert(.deleteSyncup), syncup: .mock))
//    }

//    NavigationStack {
//        SyncupDetailView(model: SyncupDetailModel(syncup: .mock))
//    }
}
