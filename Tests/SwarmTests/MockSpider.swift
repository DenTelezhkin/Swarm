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
    let url : ScrappableURL
    
    required init(url: ScrappableURL) {
        self.url = url
    }
    
    @discardableResult func stubResponse(_ data: Data? = nil, _ response: URLResponse? = nil, _ error: Error? = nil) -> Self {
        self.data = data
        self.response = response
        self.error = error
        return self
    }
    
    @discardableResult func stubSuccess(data: Data = .init(), statusCode: Int = 200) -> Self {
        self.data = data
        self.response = HTTPURLResponse.withStatus(statusCode)
        self.error = nil
        return self
    }
    
    @discardableResult func stubFailure(error: Error, statusCode: Int) -> Self {
        self.data = nil
        self.error = error
        self.response = HTTPURLResponse.withStatus(statusCode)
        return self
    }
    
    var conditionalSetup : ((MockSpider) -> ())?
    func conditionallyStub(_ closure: @escaping (MockSpider) -> ()) {
        conditionalSetup = closure
    }
    
    var data: Data? = nil
    var response: URLResponse? = nil
    var error: Error? = nil
    
    var requestCount = 0
    
    func request(completion: @escaping (Data?, URLResponse?, Error?) -> Void) {
        requestCount += 1
        if let conditionalSetup = conditionalSetup {
            conditionalSetup(self)
        }
        completion(data, response, error)
    }
}

private extension HTTPURLResponse {
    static func withStatus(_ statusCode: Int) -> HTTPURLResponse {
        return HTTPURLResponse(url: NSURL() as URL, statusCode: statusCode, httpVersion: "HTTP/1.1", headerFields: nil)!
    }
}
