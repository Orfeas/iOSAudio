//
//  TimePoint.swift
//  iOSAudio
//
//  Created by Orfeas Iliopoulos on 28/2/21.
//

import Foundation

typealias TimePoints = [TimePoint]
struct TimePoint: Decodable {
    var markName: String?
    var timeSeconds: Int
}
