//
//  RecordViewModel.swift
//  iOSAudio
//
//  Created by Orfeas Iliopoulos on 28/2/21.
//

import Foundation
import AVFoundation

enum PlaybackType: Int {
    case google
    case apple
}

final class RecordViewModel: NSObject, ObservableObject {
    @Published var transcription = Transcription()
    
    var manager: GoogleSpeechManager?
    
    private var player = AVAudioPlayer()
    private var synthesizer = AVSpeechSynthesizer()

    private var lastTrascribedText = ""
    
    override init() {
        super.init()
        manager = GoogleSpeechManager(delegate: self)
    }

    func startRecording() {
        transcription.transcribedText = nil
        manager?.startRecording()
    }
    
    func stopRecording() {
        lastTrascribedText.removeAll()
        manager?.stopRecording()
    }
    
    func startSpeakingTextWithPlaybackType(_ playbackType: PlaybackType) {
        guard let transcribedText = transcription.transcribedText else {
            return
        }
        
        do {
            let _ = try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback,
                                                                    options: .duckOthers)

        } catch {
            transcription.didFailToPlayback = true
        }
        switch playbackType {
            case .apple:
                
                let utterance = AVSpeechUtterance(string: transcribedText)
                utterance.voice = AVSpeechSynthesisVoice(language: "\(Locale.current.languageCode ?? "en")-\(Locale.current.regionCode ?? "GB")")

                    synthesizer = AVSpeechSynthesizer()
                    synthesizer.delegate = self
                    synthesizer.speak(utterance)
            default:
                GoogleAPIServices.getAudioFromText(transcribedText) {[weak self] audioFromText in
                    
                    guard let audioData = audioFromText.audioContent else {
                        self?.transcription.didFailToPlayback = true

                        return
                    }

                    DispatchQueue.main.async {[weak self] in
                        do {
                            self?.player = try AVAudioPlayer(data: audioData)
                            self?.player.prepareToPlay()
                            self?.player.delegate = self
                            self?.player.play()
                        } catch {
                            self?.transcription.didFailToPlayback = true
                        }
                    }
                    

                } failure: {[weak self] error in
                    self?.transcription.didFailToPlayback = true
                }
        }
        
    }
    
    func stopSpeakingText() {
        player.stop()
    }
}

extension RecordViewModel: GoogleSpeechManagerDelegate {
    func didTranscribeText(_ text: String) {
        DispatchQueue.main.async {[weak self] in
            guard let `self` = self else { return }
            self.transcription.transcribedText = self.lastTrascribedText + text
            self.lastTrascribedText = self.transcription.transcribedText ?? ""
        }
    }
    
    func didFailWithError(_ error: Error) {
        transcription.trascribedError = error
        transcription.didFinishWithError = true
    }
}

extension RecordViewModel: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        transcription.didFinishPlayback = true
    }
}

extension RecordViewModel: AVSpeechSynthesizerDelegate {
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, willSpeakRangeOfSpeechString characterRange: NSRange, utterance: AVSpeechUtterance) {
        transcription.playbackWordRange = characterRange
    }

    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        transcription.didFinishPlayback = true
        transcription.playbackWordRange = nil

    }
}
