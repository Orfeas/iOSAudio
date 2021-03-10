//
//  GoogleSpeechManager.swift
//  iOSAudio
//
//  Created by Orfeas Iliopoulos on 28/2/21.
//

import Foundation
import AVFoundation
import googleapis

protocol GoogleSpeechManagerDelegate {
    func didTranscribeText(_ text: String)
    func didFailWithError(_ error: Error)
}

class GoogleSpeechManager: ObservableObject {
    
    var delegate: GoogleSpeechManagerDelegate?

    var audioData = NSMutableData()
    
    // Hold here the last trasncribed txt in order to add the transcribed text to it
    var currentTranscribedText = ""
    
    init(delegate: GoogleSpeechManagerDelegate) {
        self.delegate = delegate
        AudioController.sharedInstance.delegate = self
    }

    func startRecording() {
        currentTranscribedText.removeAll()

        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(AVAudioSession.Category.record)
        } catch {

        }
        audioData = NSMutableData()
        _ = AudioController.sharedInstance.prepare(specifiedSampleRate: 16000)
        SpeechRecognitionService.sharedInstance.sampleRate = 16000
        _ = AudioController.sharedInstance.start()
    }
    
    func stopRecording() {
        _ = AudioController.sharedInstance.stop()
        SpeechRecognitionService.sharedInstance.stopStreaming()
    }
}

extension GoogleSpeechManager: AudioControllerDelegate {
    func processSampleData(_ data: Data) {
        audioData.append(data)

        // We recommend sending samples in 100ms chunks
        let chunkSize : Int /* bytes/chunk */ = Int(0.1 /* seconds/chunk */
          * Double(16000) /* samples/second */
          * 2 /* bytes/sample */);

        if (audioData.length > chunkSize) {
          SpeechRecognitionService.sharedInstance.streamAudioData(audioData,
                                                                  completion:
            { (response, error) in
                
                DispatchQueue.main.async {[weak self] in
                    guard let `self` = self else { return }

                    if let error = error {
                        self.delegate?.didFailWithError(error)
                    } else if let response = response {
                        
                        for result in response.resultsArray! {
                            if let result = result as? StreamingRecognitionResult,
                               result.isFinal,
                               let alternative = result.alternativesArray.firstObject as? SpeechRecognitionAlternative {
                                
                                self.delegate?.didTranscribeText(alternative.transcript)
                            }
                        }
                    }
                }
          })
            audioData = NSMutableData()
        }
    }
}
