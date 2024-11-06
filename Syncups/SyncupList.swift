//
//  SyncupList.swift
//  Syncups
//
//  Created by Vanya Mutafchieva on 23/10/2024.
//

import Combine
import Dependencies
import IdentifiedCollections
import SwiftUINavigation
import SwiftUI

@MainActor
final class SyncupListModel: ObservableObject {
    @Published var syncups: IdentifiedArrayOf<Syncup> // [Syncup]
    //@Published var addSyncup: Syncup? // nill - the addSyncup sheet is presented, non-nill - the sheet is presented
    
    private var destinationCancellable: AnyCancellable? // specifically used when we need to subscribe to updates in a destination
    private var cancellables: Set<AnyCancellable> = []
    
    @Dependency(\.mainQueue) var mainQueue
    
    @Published var destination: Destination? { // (instead of addSyncup) we hold on to a single piece of state to represent us navigating to a destination, but it's Optional (nill represents we are not navigated anywhere, and non-nill represents we are navigated to one of the Destinations)
        didSet { bind() } // bind to the onConfirmDeletion closure (SyncupDetail) // we are now intergrating a parent and a child features together so they can now communicate with each other
    }
        
    // models all possible destinations we can navigate to
    @CasePathable //the @CasePathable macro allows one to refer to the cases of an enum with dot-syntax just like one does with structs and properties
    enum Destination {
        case add(EditSyncupModel) // case add(Syncup) // we now pass in the model instead of a simple syncup value
        case detail(SyncupDetailModel)
    }
    
    init(destination: Destination? = nil) {
        self.destination = destination // we add destination to init because whoever creates the model will have the oportunity to have destination hydrated and that's what unlocks deep linking capabilities
        self.syncups = [] // self.syncups = syncups // 1. we give up initialising the syncups here as it conflicts too much with the persistence logic
        
        // 2. we try to load up any previously saved data
        do {
            syncups = try JSONDecoder().decode(IdentifiedArray.self, from: Data(contentsOf: .syncups))
        } catch {
            // TODO: alert
        }
        
        $syncups
            .dropFirst() // small optimisation: no need to save the first emission because it's going to be whatever we loaded
            .debounce(for: .seconds(1), scheduler: mainQueue) // .debounce(for: .seconds(1), scheduler: DispatchQueue.main) // we reach out to the global uncontrollable main queue to perform this debouncing work. This made it difficult to write test for persistence since we literally had to wait for time to pass. the dependencis library comes with controllable combine schedulers // we wait for a silent period of 1 sec before doing a save to space out the saves
            .sink { syncups in //we get a warning result of call to sink is unused, and that's because it returns a Cancellable, and we should keep track of it, so we'll do .store(in ...) below
            do {
                try JSONEncoder().encode(syncups).write(to: .syncups)
            } catch {
                // TODO: alert
            }
        }
            .store(in: &cancellables)
        
        bind() // bind to the onConfirmDeletion closure (SyncupDetail)
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
    
    func syncupTapped(syncup: Syncup) {
        destination = .detail(SyncupDetailModel(syncup: syncup))
    }
    
    // bind() binds to the onConfirmDeletion closure anytime the destination switches to .detail
    private func bind() {
        switch destination {
        case let.detail(syncupDetailModel):
            syncupDetailModel.onConfirmDeletion = { [weak self, id = syncupDetailModel.syncup.id] in // to avoid a retain cycle we capture self weakly, and also capture teh id of the syncup
                guard let self else { return } // we unwrap self, otherwise early out  // this is instead of if let self {...}
                withAnimation {
                    //self.syncups.removeAll { $0.id == id } // delete the item in the array
                    self.syncups.remove(id: id)
                    self.destination = nil // pop that screen off the stack
                }
            }
            
            // Note: this model binding logic is getting a bit complex!! but the amazing thing is that because it's all (parent and child features) integrated together at the model level it'a all 100% testable
            destinationCancellable = syncupDetailModel.$syncup // syncupDetailModel.$syncup - @Published property syncup, which is a Publisher that emits any time this syncup changes
                .sink { [weak self] syncup in // so we sink on it so we can get access to the newest syncup (and we don't want any retain cycles)
                    guard let self else { return }  // we unwrap it
                    //guard let index = syncups.firstIndex(where: { $0.id == syncup.id }) else { return }
                    //syncups[index] = syncup // and mutate our syncups with this new syncup
                    syncups[id: syncup.id] = syncup
                }
            
        case .add, .none:
            break
        }
    }
}

struct SyncupList: View {
    
    @ObservedObject var model: SyncupListModel
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(model.syncups) { syncup in
                    Button {
                        model.syncupTapped(syncup: syncup)
                    } label: {
                        CardView(syncup: syncup)
                    }
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
            .navigationDestination(item: $model.destination.detail) { $detailModel in
                SyncupDetailView(model: detailModel)
            }
//            .sheet(item: $model.destination.detail) { detailModel in
//                SyncupDetailView(model: detailModel)
//            }
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
        Label("\(syncup.duration.formatted(.units()))", systemImage: "clock")
            .accessibilityLabel("\(syncup.duration.formatted(.units())) minute meeting")
            .labelStyle(.trailingIcon)
    }
}

struct TrailingIconLabelStyle: LabelStyle {
  func makeBody(configuration: Configuration) -> some View {
    HStack {
      configuration.title
      configuration.icon
    }
  }
}

extension LabelStyle where Self == TrailingIconLabelStyle {
  static var trailingIcon: Self { Self() }
}

extension URL {
  fileprivate static let syncups = Self.documentsDirectory.appending(component: "sync-ups.json")
}

#Preview {
    SyncupList(
        model: SyncupListModel(
            destination: .detail(
                SyncupDetailModel(
                    //destination: .meeting(Syncup.mock.meetings[0]),
                    syncup: .mock))
//            destination: .add(
//                EditSyncupModel(
//                    focus: .attendee(Syncup.mock.attendees[3].id),
//                    syncup: .mock)),
        )
    )
}
