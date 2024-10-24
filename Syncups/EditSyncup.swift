//
//  EditSyncup.swift
//  Syncups
//
//  Created by Vanya Mutafchieva on 24/10/2024.
//

import SwiftUI
import SwiftUINavigation

struct EditSyncupView: View {
    @Binding var syncup: Syncup
    
    enum Field: Hashable {
        case attendee(Attendee.ID)
        case title
    }
    
    @FocusState var focus: Field? // providing a default to @FocusState is not allowed
    
    var body: some View {
        Form {
            Section {
                TextField("Title", text: $syncup.title)
                    .focused($focus, equals: .title)
                HStack {
                    Slider(value: $syncup.duration.seconds, in: 5...30, step: 1) {
                        Text("Length")
                    }
                    Spacer()
                    Text(syncup.duration.formatted(.units()))
                }
                ThemePicker(selection: $syncup.theme)
            } header: {
                Text("Sync-up Info")
            }
             
            Section {
                ForEach($syncup.attendees) { $attendee in
                    TextField("Name", text: $attendee.name)
                        .focused($focus, equals: .attendee(attendee.id))
                }
                .onDelete { indices in
                    //model.deleteAttendees(atOffsets: indices)
                    syncup.attendees.remove(atOffsets: indices)
                    if syncup.attendees.isEmpty {
                        syncup.attendees.append(Attendee(id: Attendee.ID(UUID()), name: ""))
                    }
                    focus = .attendee(syncup.attendees[indices.first!].id)
                }
                
                Button("New attendee") {
                    //model.addAttendeeButtonTapped()
                    let attendee = Attendee(id: Attendee.ID(UUID()), name: "")
                    syncup.attendees.append(attendee)
                    focus = .attendee(attendee.id)
                }
            } header: {
                Text("Attendees")
            }
        }
        .onAppear {
            if syncup.attendees.isEmpty {
                syncup.attendees.append(Attendee(id: Attendee.ID(UUID()), name: ""))
            }
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
    EditSyncupView(syncup: $syncup)
}
