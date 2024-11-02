//
//  Speech.swift
//  Syncups
//
//  Created by Vanya Mutafchieva on 02/11/2024.
//

@preconcurrency import Speech

actor Speech {
    private var audioEngine: AVAudioEngine? = nil
    private var recognitionTask: SFSpeechRecognitionTask? = nil
    private var recognitionContinuation:
    AsyncThrowingStream<SpeechRecognitionResult, Error>.Continuation?
    
    func startTask(
        request: SFSpeechAudioBufferRecognitionRequest
    ) -> AsyncThrowingStream<SpeechRecognitionResult, Error> {
        AsyncThrowingStream { continuation in
            self.recognitionContinuation = continuation
            let audioSession = AVAudioSession.sharedInstance()
            do {
                try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
                try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
            } catch {
                continuation.finish(throwing: error)
                return
            }
            
            self.audioEngine = AVAudioEngine()
            let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))!
            self.recognitionTask = speechRecognizer.recognitionTask(with: request) { result, error in
                switch (result, error) {
                case let (.some(result), _):
                    continuation.yield(SpeechRecognitionResult(result))
                case (_, .some):
                    continuation.finish(throwing: error)
                case (.none, .none):
                    fatalError("It should not be possible to have both a nil result and nil error.")
                }
            }
            
            continuation.onTermination = { [audioEngine, recognitionTask] _ in
                _ = speechRecognizer
                audioEngine?.stop()
                audioEngine?.inputNode.removeTap(onBus: 0)
                recognitionTask?.finish()
            }
            
            self.audioEngine?.inputNode.installTap(
                onBus: 0,
                bufferSize: 1024,
                format: self.audioEngine?.inputNode.outputFormat(forBus: 0)
            ) { buffer, when in
                request.append(buffer)
            }
            
            self.audioEngine?.prepare()
            do {
                try self.audioEngine?.start()
            } catch {
                continuation.finish(throwing: error)
                return
            }
        }
    }
}

struct SpeechRecognitionResult: Equatable {
  var bestTranscription: Transcription
  var isFinal: Bool
}

struct Transcription: Equatable {
  var formattedString: String
}

extension SpeechRecognitionResult {
  init(_ speechRecognitionResult: SFSpeechRecognitionResult) {
    self.bestTranscription = Transcription(speechRecognitionResult.bestTranscription)
    self.isFinal = speechRecognitionResult.isFinal
  }
}

extension Transcription {
  init(_ transcription: SFTranscription) {
    self.formattedString = transcription.formattedString
  }
}

