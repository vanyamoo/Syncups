//
//  RecordMeeting.swift
//  Syncups
//
//  Created by Vanya Mutafchieva on 30/10/2024.
//

import Clocks
import Dependencies
@preconcurrency import Speech
import SwiftUI
import SwiftNavigation
import XCTestDynamicOverlay


@MainActor
class RecordMeetingModel: ObservableObject {
    
    @Published var destination: Destination?
    var isDismissed = false
    @Published var secondsElapsed = 0
    @Published var speakerIndex = 0
    private var transcript = ""
    
    
    @Dependency(\.continuousClock) var clock // similar to @Environment - we provide it with a keypath // private let clock: any Clock<Duration>
    @Dependency(\.speechClient) var speechClient
    
    var onMeetingFinished: (String) -> Void = unimplemented("RecordMeetingModel.onMeetingFinished")
    let syncup: Syncup
    
    @CasePathable
    enum Destination {
        case alert(AlertState<AlertAction>)
    }
    enum AlertAction {
        case confirmSave
        case confirmDiscard
    }
    
    var durationRemaining: Duration {
        syncup.duration - .seconds(secondsElapsed)
    }
    
    init(
        //clock: any Clock<Duration> = ContinuousClock(),
        destination: Destination? = nil, syncup: Syncup
    ) {
        //self.clock = clock
        self.destination = destination
        self.syncup = syncup
    }
    
    var isAlertOpen: Bool {
        switch destination {
        case .alert:
            return true
        case .none:
            return false
        }
    }
    
    func nextButtonTapped() {
        guard speakerIndex < syncup.attendees.count - 1
        else {
            //onMeetingFinished()
            //isDismissed = true
            destination = .alert(.endMeeting(isDiscardable: false))
            return
        }
        
        speakerIndex += 1
        secondsElapsed = speakerIndex * Int(syncup.durationPerAttendee.components.seconds)
    }
    
    func endMeetingButtonTapped() {
        destination = .alert(.endMeeting(isDiscardable: true))
    }
    
//    func alertButtonTapped(_ action: AlertAction?) async {
//        switch action {
//        case .confirmSave?:
//          await finishMeeting()
//        case .confirmDiscard?:
//          isDismissed = true
//        case nil:
//          break
//        }
//      }
    func alertButtonTapped(_ action: AlertAction?) {
        switch action {
        case .confirmSave:
            onMeetingFinished(transcript)
            isDismissed = true
        case .confirmDiscard:
            isDismissed = true
//        case nil:
//          break
        case .none:
            break
        }
        
    }
    
    func task() async { // now we have a little spot in the model to start adding some asynchronous behaviour
        // one way to start a very basic timer is to start an infinite loop and do a sleep on the inside
        do {
            try await withThrowingTaskGroup(of: Void.self) { group in
                if await speechClient.requestAuthorization() == .authorized {// requestAuthorization() == .authorized {
                    group.addTask {
                        // Start speech task
                        try await self.startSpeechRecognition()
                    }
                }
                group.addTask {
                    // Timer task
                    try await self.startTimer()
                }
                try await group.waitForAll()
            }
        } catch {
            destination = .alert(AlertState(title: TextState("Something went wrong")))
        }
    }
    
    private func startSpeechRecognition() async throws {
        //let speech = Speech()
        let speechTask =  await speechClient.startTask(SFSpeechAudioBufferRecognitionRequest()) // speech.startTask(request:
        for try await result in speechTask {
            transcript = result.bestTranscription.formattedString
//            if let text = result.bestTranscription.formattedString {
//                destination = .alert(AlertState(title: TextState(text)))
//            }
        }
    }
    
    private func startTimer() async throws {
        for await _ in clock.timer(interval: .seconds(1)) where !isAlertOpen {
            // while true { try await clock.sleep(for: .seconds(1))
            // NOTE: this is not the best way to implement a timer, it is very imprecise. But we'll keep it for now. We'll address the issue of dependencies and testing later on.
            //try await Task.sleep(for: .seconds(1)) // Task.sleep can throw, and that happens when the asynchronous context is cancelled, so we need to wrap it in a do {} catch {}, bacause we don't want task() to throw since we can't throw over in the View
            //guard !isAlertOpen else { continue } // pause timer when alert is presented
            secondsElapsed += 1
            
            if secondsElapsed.isMultiple(of:
            Int(syncup.durationPerAttendee.components.seconds)) {
                if speakerIndex == syncup.attendees.count - 1 {
                    // end meeting
                    // this feature should not be solely responsible for ending the meeting, it should communicate to the parent to let them know the meeting has ended, and then the parent could do the work to pop the screen off the stack and maybe insert the meeting into the history array. Also it'd be nice to show with a little animation when the meeting is inserted into the history list. So we'll facilitaye this child-parent communication in the same way we did for the detail screen that communicated to the list screen
                    onMeetingFinished(transcript) // this only works if the parent is actually listening, and that is a very subte thing. Hence we use unimplemented above
                    break // break out the timer
                }
                speakerIndex += 1
            }
        }
    }
    
//    private func requestAuthorization() async -> SFSpeechRecognizerAuthorizationStatus {
//        await withUnsafeContinuation { continuation in
//            SFSpeechRecognizer.requestAuthorization { status in
//                continuation.resume(returning: status)
//            }
//        }
//    }
}

extension AlertState where Action == RecordMeetingModel.AlertAction {
    static func endMeeting(isDiscardable: Bool) -> Self {
        Self {
            TextState("End meeting?")
        } actions: {
            ButtonState(action: .confirmSave) {
                TextState("Save and end")
            }
            if isDiscardable {
                ButtonState(role: .destructive, action: .confirmDiscard) {
                    TextState("Discard")
                }
            }
            ButtonState(role: .cancel) {
                TextState("Resume")
            }
        } message: {
            TextState("You are ending the meeting early. What would you like to do?")
        }
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
            .task { await model.task() } // Add Timer behaviour - we need a method that can access the kickoff point for the View appearing and SwiftUI's .task ViewModifier is really nice for this. In the closure we get a little asynchronous context to execute work and when the View goes away that asynchronous context is cancelled, and that can be really handy for automatically tearing down work, and that will automatically stop our timer
//            .onChange(of: self.model.isDismissed) { _, _ in self.dismiss() }
            .alert(self.$model.destination.alert) { action in
                self.model.alertButtonTapped(action)
            }
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
    NavigationStack {
        RecordMeetingView(
            model: RecordMeetingModel(syncup: .mock))
    }
}
