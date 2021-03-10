//
//  GetTextToAudioOperation.swift
//  iOSAudio
//
//  Created by Orfeas Iliopoulos on 28/2/21.
//

import Foundation

final class GetAudioFromTextOperation: BaseOperation {
    init?(text: String,
          success: ((Any?) -> Void)?,
          failure: ( (Error?) -> Void)?) {

        var voiceParams: [String: Any] = [
            // All available voices here: https://cloud.google.com/text-to-speech/docs/voices
            "languageCode": "\(Locale.current.languageCode ?? "en")-\(Locale.current.regionCode ?? "GB")",
        ]
        
        voiceParams["name"] = "en-US-Wavenet-F"

        let params: [String: Any] = [
            "input": [
                "ssml": "<speak>\(text)<break time=\"1s\"/></speak>"
            ],
            "voice": voiceParams,
            "audioConfig": [
                // All available formats here: https://cloud.google.com/text-to-speech/docs/reference/rest/v1beta1/text/synthesize#audioencoding
                "audioEncoding": "LINEAR16"
            ],
            "enableTimePointing": [
                "SSML_MARK"
            ]
        ]
        
        guard let url = URL(string: "https://texttospeech.googleapis.com/v1beta1/text:synthesize") else {
            return nil
        }
        
        super.init(baseURL: url, requestType: .google, method: .post, parameters: params, success: success, failure: failure)
    }
}
