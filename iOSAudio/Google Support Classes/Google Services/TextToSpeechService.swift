
import UIKit
import AVFoundation

let ttsAPIUrl = "https://texttospeech.googleapis.com/v1beta1/text:synthesize"
let APIKey = "AIzaSyDWcjigouHLCqiL226Im3AfOkhSQ18D-oo"

class SpeechService: NSObject, AVAudioPlayerDelegate {

    private(set) var busy: Bool = false
    
    private var player = AVAudioPlayer()
    private var completionHandler: (() -> Void)?
    
    override init() {
        super.init()
        
    }
    
    func speak(text: String, completion: @escaping () -> Void) {
        guard !self.busy else {
            print("Speech Service busy!")
            return
        }
        
        self.busy = true
        
        

    }
    
    func stopSpeaking() {
        player.stop()
        busy = false
    }
        
    // Implement AVAudioPlayerDelegate "did finish" callback to cleanup and notify listener of completion.
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        self.player.delegate = nil
        self.busy = false
        
        self.completionHandler!()
        self.completionHandler = nil
    }
    
    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        
    }
}
