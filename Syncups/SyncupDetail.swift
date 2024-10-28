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
        Text("Detail")
    }
}

#Preview {
    SyncupDetailView(model: SyncupDetailModel(syncup: .mock))
}
