//
//  SyncupList.swift
//  Syncups
//
//  Created by Vanya Mutafchieva on 23/10/2024.
//

import SwiftUI

final class SyncupListModel: ObservableObject {
    @Published var syncups: [Syncup]
    
    init(syncups: [Syncup] = []) {
        self.syncups = syncups
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
            .navigationTitle("Daily Syncups")
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
