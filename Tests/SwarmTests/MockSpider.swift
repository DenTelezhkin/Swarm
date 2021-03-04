//
//  File.swift
//  
//
//  Created by Denys Telezhkin on 05.01.2021.
//

import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif
import Swarm

class MockSpider : Spider {
    enum Response {
        case response(Data?, URLResponse?, Error?)
        case infiniteLoading
    }
    
    var mockResponse: Response?
    
    init() {}
    
    @discardableResult func stubResponse(_ data: Data? = nil, _ response: URLResponse? = nil, _ error: Error? = nil) -> Self {
        mockResponse = .response(data, response, error)
        return self
    }
    
    @discardableResult func stubSuccess(data: Data = .init(), statusCode: Int = 200) -> Self {
        mockResponse = .response(data, HTTPURLResponse.withStatus(statusCode), nil)
        return self
    }
    
    @discardableResult func stubFailure(error: Error, statusCode: Int) -> Self {
        mockResponse = .response(nil, HTTPURLResponse.withStatus(statusCode), error)
        return self
    }
    
    @discardableResult func stubInfiniteLoading() -> Self {
        mockResponse = .infiniteLoading
        return self
    }
    
    var conditionalSetup : ((MockSpider) -> ())?
    func conditionallyStub(_ closure: @escaping (MockSpider) -> ()) {
        conditionalSetup = closure
    }
    
    var requestCount = 0
    
    func request(url: ScrappableURL, completion: @escaping (Data?, URLResponse?, Error?) -> Void) {
        requestCount += 1
        if let conditionalSetup = conditionalSetup {
            conditionalSetup(self)
        }
        switch mockResponse {
            case .response(let data, let response, let error):
                completion(data, response, error)
            case .infiniteLoading: ()
            case .none: ()
        }
    }
}

private extension HTTPURLResponse {
    static func withStatus(_ statusCode: Int) -> HTTPURLResponse {
        return HTTPURLResponse(url: URL(fileURLWithPath: ""), statusCode: statusCode, httpVersion: "HTTP/1.1", headerFields: nil)!
    }
}
