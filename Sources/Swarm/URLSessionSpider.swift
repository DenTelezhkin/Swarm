//
//  Spider.swift
//  
//
//  Created by Denys Telezhkin on 28.09.2020.
//

import Foundation

open class URLSessionSpider: Spider {
    
    public var session: URLSession = .shared
    
    public var httpShouldHandleCookies: Bool = false
    
    public var userAgent: UserAgent = .none
    
    public var httpHeaders : [String: String?] = [
        "Accept": "text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8",
        "Accept-Language": "en",
        "Accept-Encoding": "br,gzip,deflate"
    ]
    
    public var requestModifier : (URLRequest) -> URLRequest = { $0 }
    
    let url: ScrappableURL
    
    required public init(url: ScrappableURL) {
        self.url = url
    }
    
    open func urlRequest(for url: ScrappableURL) -> URLRequest {
        var request = URLRequest(url: url.url)
        request.httpShouldHandleCookies = httpShouldHandleCookies
        request.setValue(userAgent.value, forHTTPHeaderField: "User-Agent")
        for header in httpHeaders.keys {
            request.setValue(httpHeaders[header] ?? "", forHTTPHeaderField: header)
        }
        return requestModifier(request)
    }
    
    private var currentTask: URLSessionTask?
    
    public func request(completion: @escaping (Data?, URLResponse?, Error?) -> Void) {
        currentTask = session.dataTask(with: urlRequest(for: url)) { data, response, error in
            completion(data, response, error)
        }
        currentTask?.resume()
    }
}
