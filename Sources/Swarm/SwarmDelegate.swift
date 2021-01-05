//
//  SwarmDelegate.swift
//  
//
//  Created by Denys Telezhkin on 04.01.2021.
//

import Foundation

public protocol SwarmDelegate: class {
    func spider(for url: ScrappableURL) -> Spider
    func failedToScrapURL(_ url: VisitedURL)
    func scrappedURL(_ url: VisitedURL, nextScrappableURLs: @escaping ([ScrappableURL]) -> Void)
    func delayingRequest(to url: ScrappableURL, for timeInterval: TimeInterval, becauseOf response: URLResponse?)
    func scrappingCompleted()
}

public extension SwarmDelegate {
    func spider(for url: ScrappableURL) -> Spider {
        URLSessionSpider(url: url)
    }
    
    func failedToScrapURL(_ url: VisitedURL) {}
    
    func delayingRequest(to url: ScrappableURL, for timeInterval: TimeInterval, becauseOf response: URLResponse?) {}
}
