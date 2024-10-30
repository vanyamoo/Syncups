//
//  Models.swift
//  Syncups
//
//  Created by Vanya Mutafchieva on 23/10/2024.
//

import Foundation
import SwiftUI
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
    
    var accentColor: Color {
        switch self {
        case .bubblegum, .buttercup, .lavender, .orange, .periwinkle, .poppy, .seafoam, .sky, .tan, .teal, .yellow: return .black
        case .indigo, .magenta, .navy, .oxblood, .purple: return .white
        }
    }
    
    var mainColor: Color {
        Color(rawValue)
    }
    
    var name: String {
        rawValue.capitalized
    }
    var id: String {
        name
    }
}

extension Syncup {
  static let mock = Self(
    id: Syncup.ID(UUID()),
    attendees: [
      Attendee(id: Attendee.ID(UUID()), name: "Blob"),
      Attendee(id: Attendee.ID(UUID()), name: "Blob Jr"),
      Attendee(id: Attendee.ID(UUID()), name: "Blob Sr"),
      Attendee(id: Attendee.ID(UUID()), name: "Blob Esq"),
      Attendee(id: Attendee.ID(UUID()), name: "Blob III"),
      Attendee(id: Attendee.ID(UUID()), name: "Blob I"),
    ],
    duration: .seconds(60),
    meetings: [
      Meeting(
        id: Meeting.ID(UUID()),
        date: Date().addingTimeInterval(-60 * 60 * 24 * 7),
        transcript: """
          Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor \
          incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud \
          exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure \
          dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. \
          Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt \
          mollit anim id est laborum.
          """
      ),
      Meeting(
        id: Meeting.ID(UUID()),
        date: Date().addingTimeInterval(-60 * 60 * 24 * 7),
        transcript: """
          This is the second meeting.
          """
      )
    ],
    theme: .orange,
    title: "Design"
  )

  static let engineeringMock = Self(
    id: Syncup.ID(UUID()),
    attendees: [
      Attendee(id: Attendee.ID(UUID()), name: "Blob"),
      Attendee(id: Attendee.ID(UUID()), name: "Blob Jr"),
    ],
    duration: .seconds(60 * 10),
    meetings: [],
    theme: .periwinkle,
    title: "Engineering"
  )

  static let designMock = Self(
    id: Syncup.ID(UUID()),
    attendees: [
      Attendee(id: Attendee.ID(UUID()), name: "Blob Sr"),
      Attendee(id: Attendee.ID(UUID()), name: "Blob Jr"),
    ],
    duration: .seconds(60 * 30),
    meetings: [],
    theme: .poppy,
    title: "Product"
  )
}
