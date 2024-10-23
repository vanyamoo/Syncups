//
//  Models.swift
//  Syncups
//
//  Created by Vanya Mutafchieva on 23/10/2024.
//

import Foundation
import Tagged

struct Syncup: Identifiable, Codable, Equatable {
    let id: Tagged<Self, UUID> // Tagged version of the UUID tagging with Self (which is a Syncup)
    var attendees: [Attendee] = []
    var duration = Duration.seconds(60 * 5)
    var meetings: [Meeting] = []
    var theme: Theme = .bubblegum
    var title = ""
    
    var durationPerAttendee: Duration {
        duration / attendees.count
    }
}

struct Attendee: Identifiable, Codable, Equatable {
    let id: Tagged<Self, UUID>
    var name: String
}

struct Meeting: Identifiable, Codable, Equatable {
    let id: Tagged<Self, UUID>
    var date: Date
    var transcript: String
}

enum Theme: String, CaseIterable, Identifiable, Codable {

    case bubblegum
    case buttercup
    case indigo
    case lavender
    case magenta
    case navy
    case orange
    case oxblood
    case periwinkle
    case poppy
    case purple
    case seafoam
    case sky
    case tan
    case teal
    case yellow
    
//    var accentColor: Color {
//        switch self {
//        case .bubblegum, .buttercup, .lavender, .orange, .periwinkle, .poppy, .seafoam, .sky, .tan, .teal, .yellow: return .black
//        case .indigo, .magenta, .navy, .oxblood, .purple: return .white
//        }
//    }
//    var mainColor: Color {
//        Color(rawValue)
//    }
    var name: String {
        rawValue.capitalized
    }
    var id: String {
        name
    }
}
