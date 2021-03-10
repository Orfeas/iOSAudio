//
//  BaseNetworkingOperation.swift
//  GalleryScanDemo
//
//  Created by Orfeas Iliopoulos on 24/04/2018.
//  Copyright © 2018 Orfeas. All rights reserved.
//

import Foundation
import Alamofire


extension String: ParameterEncoding {
    public func encode(_ urlRequest: URLRequestConvertible, with parameters: Parameters?) throws -> URLRequest {
        var request = try urlRequest.asURLRequest()
        request.httpBody = data(using: .utf8, allowLossyConversion: false)
        return request
    }
}

enum APIRequestType {
    case `default`
    case google
}

class BaseOperation: Foundation.Operation {
    // MARK: - Variables

    private(set) var baseURL: URL!
    var method: HTTPMethod = .post
    var parameters: [String: Any]? = [:]
    var timeout = 30.0
    var success: ((Any?) -> Void)?
    var failure: ( (Error?) -> Void)?
    var isRetryOperation: Bool = true
    var reqHeaders: HTTPHeaders?
    var requestType: APIRequestType = .default
    
    var operationIsFinished = false
    override var isFinished: Bool {
        get {
            return operationIsFinished
        }
        set {
            willChangeValue(forKey: "isFinished")
            operationIsFinished = newValue
            didChangeValue(forKey: "isFinished")
        }
    }

    // MARK: - LifeCycle

    // Use baseURL only exceptionally
    init(baseURL: URL,
         requestType: APIRequestType,
         method: HTTPMethod,
         parameters: [String: Any]?,
         success: ((Any?) -> Void)?,
         failure: ( (Error?) -> Void)?,
         isRetryOperation: Bool = true) {
        super.init()
        self.baseURL = baseURL
        self.requestType = requestType
        self.method = method
        self.parameters = parameters
        self.success = success
        self.failure = failure
        self.isRetryOperation = isRetryOperation
        
    }

    override init() {
        super.init()
    }

    override func main() {

        if isCancelled {
            isFinished = true
            return
        }
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = timeout

        makeAPIRequest()

        if isCancelled {
            isFinished = true
            return
        }
    }

    private func makeAPIRequest() {
        var encoding: ParameterEncoding!

        if method == .get {
            encoding = URLEncoding.default
        } else {
            encoding = JSONEncoding.default
        }

        AF.request(baseURL,
        method: method,
        parameters: parameters as [String: AnyObject]?,
        encoding: encoding,
        headers: getHeaders()).responseJSON(completionHandler: { (responseObject) -> Void in
        self.process(dataResponse: responseObject)
        self.isFinished = true
        })
    }
    
    private func getHeaders() -> HTTPHeaders {
        var mutableHeaders = [String: String]()

        mutableHeaders["Accept-Language"] = "Locale.deviceLocale()"
        
        if requestType == .google {
            mutableHeaders["X-Goog-Api-Key"] = "AIzaSyDWcjigouHLCqiL226Im3AfOkhSQ18D-oo"
        }
        
        // Check if there is a body in the request
        if parameters != nil {
            mutableHeaders["Content-Type"] = "application/json; charset=utf-8"
        }

        reqHeaders = HTTPHeaders(mutableHeaders)

        return reqHeaders!
    }
}

// MARK: - API request

extension BaseOperation {
    private func process(dataResponse: AFDataResponse<Any>) {

        switch dataResponse.result {
        case let .failure(error):
            if let statusCode = dataResponse.response?.statusCode {
                switch statusCode {
                case 200 ... 299:
                    success?(dataResponse.response)
                default:
                    failure?(error)
                }
            } else {
                failure?(error)
            }

        case let .success(response):

            if let statusCode = dataResponse.response?.statusCode {
                switch statusCode {
                case 200 ... 299:
                    success?(response)
                default:
                    failure?(nil)
                }
            }
        }
    }
}
