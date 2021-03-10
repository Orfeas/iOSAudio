//
//  Speech.swift
//  iOSAudio
//
//  Created by Orfeas Iliopoulos on 28/2/21.
//

import Foundation

struct Transcription {
    
    var transcribedText: String?
    var trascribedError: Error?
    var playbackWordRange: NSRange?
    var didFinishTranscribing = true
    var didFinishWithError = false
    var didFinishPlayback = true
    var didFailToPlayback = false
}
