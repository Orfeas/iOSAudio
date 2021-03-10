//
//  AudioFromText.swift
//  iOSAudio
//
//  Created by Orfeas Iliopoulos on 28/2/21.
//

import Foundation

struct AudioFromText: Decodable {
    var audioContent: Data?
    var timepoints: TimePoints?
}

final class TextToAudioSerializer {
    static var decoder: JSONDecoder {
        let lazyDecoder = JSONDecoder()
        lazyDecoder.keyDecodingStrategy = .convertFromSnakeCase

        return lazyDecoder
    }

    class func getAudioFromResponse(response: [String: Any]) -> AudioFromText? {
        do {
            let data = try JSONSerialization.data(withJSONObject: response, options: .prettyPrinted)
            let audioFromText = try decoder.decode(AudioFromText.self, from: data)
            return audioFromText
        } catch {
            return nil
        }
    }
}
