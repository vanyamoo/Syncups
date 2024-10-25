//
//  EditSyncup.swift
//  Syncups
//
//  Created by Vanya Mutafchieva on 24/10/2024.
//

import SwiftUI
import SwiftUINavigation

class EditSyncupModel: ObservableObject, Identifiable {
    @Published var syncup: Syncup
    
    init(syncup: Syncup) {
        self.syncup = syncup
        
        if syncup.attendees.isEmpty {
            self.syncup.attendees.append(Attendee(id: Attendee.ID(UUID()), name: ""))
        }
        //focus = .title
    }
    
    func deleteAttendees(atOffsets indices: IndexSet) {
        syncup.attendees.remove(atOffsets: indices)
        if syncup.attendees.isEmpty {
            syncup.attendees.append(Attendee(id: Attendee.ID(UUID()), name: ""))
        }
        //focus = .attendee(syncup.attendees[indices.first!].id)
    }
    
    func addAttendeeButtonTapped() {
        let attendee = Attendee(id: Attendee.ID(UUID()), name: "")
        syncup.attendees.append(attendee)
        //focus = .attendee(attendee.id)
    }
}

struct EditSyncupView: View {
    //@Binding var syncup: Syncup
    @ObservedObject var model: EditSyncupModel
    
    enum Field: Hashable {
        case attendee(Attendee.ID)
        case title
    }
    
    @FocusState var focus: Field? // providing a default to @FocusState is not allowed
    
    var body: some View {
        Form {
            Section {
                TextField("Title", text: $model.syncup.title)
                    .focused($focus, equals: .title)
                HStack {
                    Slider(value: $model.syncup.duration.seconds, in: 5...30, step: 1) {
                        Text("Length")
                    }
                    Spacer()
                    Text(model.syncup.duration.formatted(.units()))
                }
                ThemePicker(selection: $model.syncup.theme)
            } header: {
                Text("Sync-up Info")
            }
             
            Section {
                ForEach($model.syncup.attendees) { $attendee in
                    TextField("Name", text: $attendee.name)
                        .focused($focus, equals: .attendee(attendee.id))
                }
                .onDelete { indices in
                    model.deleteAttendees(atOffsets: indices)
                    focus = .attendee(model.syncup.attendees[indices.first!].id)
                }
                
                Button("New attendee") {
                    model.addAttendeeButtonTapped()
                    focus = .attendee(model.syncup.attendees.last!.id)
                }
            } header: {
                Text("Attendees")
            }
        }
        .onAppear {
            focus = .title
        }
    }
}

struct ThemePicker: View {
  @Binding var selection: Theme

  var body: some View {
    Picker("Theme", selection: $selection) {
      ForEach(Theme.allCases) { theme in
        ZStack {
          RoundedRectangle(cornerRadius: 4)
            .fill(theme.mainColor)
          Label(theme.name, systemImage: "paintpalette")
            .padding(4)
        }
        .foregroundColor(theme.accentColor)
        .fixedSize(horizontal: false, vertical: true)
        .tag(theme)
      }
    }
  }
}

extension Duration {
  fileprivate var seconds: Double {
    get { Double(components.seconds / 60) }
    set { self = .seconds(newValue * 60) }
  }
}

//struct PreviewContainer: View {
//    @State private var syncup: Syncup = Syncup.mock
//    var body: some View {
//        EditSyncupView(syncup: $syncup)
//    }
//}

#Preview {
    //PreviewContainer() // pre-iOS18
    @Previewable @State var syncup: Syncup = Syncup.mock
    EditSyncupView(model: EditSyncupModel(syncup: syncup))
}
