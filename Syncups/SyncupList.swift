//
//  SyncupList.swift
//  Syncups
//
//  Created by Vanya Mutafchieva on 23/10/2024.
//

import SwiftUINavigation
import SwiftUI

final class SyncupListModel: ObservableObject {
    @Published var syncups: [Syncup]
    //@Published var addSyncup: Syncup? // nill - the addSyncup sheet is presented, non-nill - the sheet is presented
    @Published var destination: Destination? // (instead of addSyncup) we hold on to a single piece of state to represent us navigating to a destination, but it's Optional (nill represents we are not navigated anywhere, and non-nill represents we are navigated to one of the Destinations)
    
    // models all possible destinations we can navigate to
    @CasePathable //the @CasePathable macro allows one to refer to the cases of an enum with dot-syntax just like one does with structs and properties
    enum Destination {
        case add(EditSyncupModel) // case add(Syncup) // we now pass in the model instead of a simple syncup value
    }
    
    init(destination: Destination? = nil, syncups: [Syncup] = []) {
        self.destination = destination // we add destination to init because whoever creates the model will have the oportunity to have destination hydrated and that's what unlocks deep linking capabilities
        self.syncups = syncups
    }
    
    func addSyncupButtonTapped() {
        // and here we hydrate the destination state
        // Note: We are reaching out to this global, uncontrolled dependency for generating a random
        //      UUID. That is going to make testing very difficult, and one of the main reasons to
        //      extract the view’s logic into an observable object is testability.
        self.destination = .add(EditSyncupModel(syncup: Syncup(id: Syncup.ID(UUID())))) // we now wrap the syncup in a Model
    }
    
    func dismissAddSyncupButtonTapped() {
        destination = nil
    }
    
    func confirmAddSyncupButtonTapped() {
        defer { destination = nil } // no matter what happend we'll clear the sheet
//        if let destination {
//            switch destination {
//            case let .add(newSyncup):
//                syncups.append(newSyncup)
//            }
//        }
        
        guard case let .add(editSyncupModel) = destination else { return }
        var newSyncup = editSyncupModel.syncup
        
        newSyncup.attendees.removeAll { attendee in
            attendee.name.allSatisfy(\.isWhitespace) // remove attendees with empty names
        }
        if newSyncup.attendees.isEmpty {
            newSyncup.attendees.append(Attendee(id: Attendee.ID(UUID()), name: ""))
        }
        syncups.append(newSyncup)
    }
}

struct SyncupList: View {
    
    @ObservedObject var model: SyncupListModel
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(model.syncups) { syncup in
                    CardView(syncup: syncup)
                        .listRowBackground(syncup.theme.mainColor)
                }
            }
            .toolbar {
                Button {
                    model.addSyncupButtonTapped()
                } label: {
                    Image(systemName: "plus")
                }
            }
            .navigationTitle("Daily Syncups")
//            .sheet(item: $model.destination.add) { model in
//                Text("")
//            }
            .sheet(item: $model.destination.add) { model in //$syncup in
                NavigationStack {
                    EditSyncupView(model: model)
                        .navigationTitle("New Syncup")
                        .toolbar {
                            ToolbarItem(placement: .cancellationAction) {
                                Button("Dismiss") {
                                    self.model.dismissAddSyncupButtonTapped()
                                }
                            }
                            
                            ToolbarItem(placement: .confirmationAction) {
                                Button("Add") {
                                    self.model.confirmAddSyncupButtonTapped()
                                }
                            }
                        }
                }
            }
        }
    }
}

struct CardView: View {
    
    let syncup: Syncup
    
    var body: some View {
        VStack(alignment: .leading) {
            title
            Spacer()
            HStack {
                attendeesLabel
                Spacer()
                minutesLabel
            }
            .font(.caption)
        }
        .padding()
        .foregroundColor(syncup.theme.accentColor)
    }
    
    private var title: some View {
        Text(syncup.title)
            .font(.headline)
            .accessibilityAddTraits(.isHeader)
    }
    
    private var attendeesLabel: some View {
        Label("\(syncup.attendees.count)", systemImage: "person.3")
            .accessibilityLabel("\(syncup.attendees.count) attendees")
    }
    
    private var minutesLabel: some View {
        Label("\(syncup.duration)", systemImage: "clock")
            .accessibilityLabel("\(syncup.duration) minute meeting")
            //.labelStyle(.trailingIcon)
    }
}

#Preview {
    SyncupList(model: SyncupListModel(syncups: [.mock]))
}
