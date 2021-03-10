//
//  GoogleAPIServices.swift
//  iOSAudio
//
//  Created by Orfeas Iliopoulos on 28/2/21.
//

import Foundation

class GoogleAPIServices {
    static let sharedQueue = OperationQueue()
    
    class func getAudioFromText(_ text: String, success: ((AudioFromText) -> Void)?, failure: ((Error?) -> Void)?) {
        guard let getAudioFromTextOperation = GetAudioFromTextOperation(text: text, success: { response in
            guard let response = response as? [String: Any],
                  let textToAudio = TextToAudioSerializer.getAudioFromResponse(response: response)
            else {
                failure?(nil)
                return
            }
            
            success?(textToAudio)
        }, failure: { error in
            failure?(error)
        }) else {
            failure?(nil)
            return
        }
        sharedQueue.addOperation(getAudioFromTextOperation)
    }
}
