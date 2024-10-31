//
//  RecordMeeting.swift
//  Syncups
//
//  Created by Vanya Mutafchieva on 30/10/2024.
//

import SwiftUI

class RecordMeetingModel: ObservableObject {
    let syncup: Syncup
    @Published var secondsElapsed = 0
    @Published var speakerIndex = 0
    
    var durationRemaining: Duration {
        syncup.duration - .seconds(secondsElapsed)
    }
    
    init(syncup: Syncup) {
        self.syncup = syncup
    }
    
    func nextButtonTapped() {
        
    }
    
    func endMeetingButtonTapped() {
        
    }
}

struct RecordMeetingView: View {
    @ObservedObject var model: RecordMeetingModel
    
    var body: some View {
        ZStack {
              RoundedRectangle(cornerRadius: 16)
                .fill(model.syncup.theme.mainColor)

              VStack {
                MeetingHeaderView(
                  secondsElapsed: model.secondsElapsed,
                  durationRemaining: model.durationRemaining,
                  theme: model.syncup.theme
                )
                MeetingTimerView(
                  syncup: model.syncup,
                  speakerIndex: model.speakerIndex
                )
                MeetingFooterView(
                  syncup: model.syncup,
                  nextButtonTapped: { model.nextButtonTapped() },
                  speakerIndex: model.speakerIndex
                )
              }
            }
            .padding()
            .foregroundColor(model.syncup.theme.accentColor)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
              ToolbarItem(placement: .cancellationAction) {
                Button("End meeting") {
                  model.endMeetingButtonTapped()
                }
              }
            }
            .navigationBarBackButtonHidden(true)
//            .alert(self.$model.destination.alert) { action in
//              await self.model.alertButtonTapped(action)
//            }
//            .task { await self.model.task() }
//            .onChange(of: self.model.isDismissed) { _, _ in self.dismiss() }
    }
}

struct MeetingHeaderView: View {
  let secondsElapsed: Int
  let durationRemaining: Duration
  let theme: Theme

  var body: some View {
    VStack {
      ProgressView(value: progress)
        .progressViewStyle(MeetingProgressViewStyle(theme: theme))
      HStack {
        VStack(alignment: .leading) {
          Text("Time Elapsed")
            .font(.caption)
          Label(
            Duration.seconds(secondsElapsed).formatted(.units()),
            systemImage: "hourglass.bottomhalf.fill"
          )
        }
        Spacer()
        VStack(alignment: .trailing) {
          Text("Time Remaining")
            .font(.caption)
          Label(durationRemaining.formatted(.units()), systemImage: "hourglass.tophalf.fill")
            .font(.body.monospacedDigit())
            .labelStyle(.trailingIcon)
        }
      }
    }
    .padding([.top, .horizontal])
  }

  private var totalDuration: Duration {
    .seconds(secondsElapsed) + durationRemaining
  }

  private var progress: Double {
    guard totalDuration > .seconds(0) else { return 0 }
    return Double(secondsElapsed) / Double(totalDuration.components.seconds)
  }
}

struct MeetingProgressViewStyle: ProgressViewStyle {
  var theme: Theme

  func makeBody(configuration: Configuration) -> some View {
    ZStack {
      RoundedRectangle(cornerRadius: 10.0)
        .fill(theme.accentColor)
        .frame(height: 20.0)

      ProgressView(configuration)
        .tint(theme.mainColor)
        .frame(height: 12.0)
        .padding(.horizontal)
    }
  }
}

struct MeetingTimerView: View {
  let syncup: Syncup
  let speakerIndex: Int

  var body: some View {
    Circle()
      .strokeBorder(lineWidth: 24)
      .overlay {
        VStack {
          Group {
            if speakerIndex < syncup.attendees.count {
              Text(syncup.attendees[speakerIndex].name)
            } else {
              Text("Someone")
            }
          }
          .font(.title)
          Text("is speaking")
          Image(systemName: "mic.fill")
            .font(.largeTitle)
            .padding(.top)
        }
        .foregroundStyle(syncup.theme.accentColor)
      }
      .overlay {
        ForEach(Array(syncup.attendees.enumerated()), id: \.element.id) { index, attendee in
          if index < speakerIndex + 1 {
            SpeakerArc(totalSpeakers: syncup.attendees.count, speakerIndex: index)
              .rotation(Angle(degrees: -90))
              .stroke(syncup.theme.mainColor, lineWidth: 12)
          }
        }
      }
      .padding(.horizontal)
  }
}

struct SpeakerArc: Shape {
  let totalSpeakers: Int
  let speakerIndex: Int

  func path(in rect: CGRect) -> Path {
    let diameter = min(rect.size.width, rect.size.height) - 24.0
    let radius = diameter / 2.0
    let center = CGPoint(x: rect.midX, y: rect.midY)
    return Path { path in
      path.addArc(
        center: center,
        radius: radius,
        startAngle: startAngle,
        endAngle: endAngle,
        clockwise: false
      )
    }
  }

  private var degreesPerSpeaker: Double {
    360.0 / Double(totalSpeakers)
  }
  private var startAngle: Angle {
    Angle(degrees: degreesPerSpeaker * Double(speakerIndex) + 1.0)
  }
  private var endAngle: Angle {
    Angle(degrees: startAngle.degrees + degreesPerSpeaker - 1.0)
  }
}

struct MeetingFooterView: View {
  let syncup: Syncup
  var nextButtonTapped: () -> Void
  let speakerIndex: Int

  var body: some View {
    VStack {
      HStack {
        if speakerIndex < syncup.attendees.count - 1 {
          Text("Speaker \(speakerIndex + 1) of \(syncup.attendees.count)")
        } else {
          Text("No more speakers.")
        }
        Spacer()
        Button(action: nextButtonTapped) {
          Image(systemName: "forward.fill")
        }
      }
    }
    .padding([.bottom, .horizontal])
  }
}

#Preview {
    RecordMeetingView(
        model: RecordMeetingModel(syncup: .mock))
}
