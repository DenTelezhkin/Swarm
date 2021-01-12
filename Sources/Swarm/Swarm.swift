//
//  Swarm.swift
//  Swarm
//
//  Created by Denys Telezhkin on 12.01.21.
//  Copyright © 2021 Denys Telezhkin. All rights reserved.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

import Foundation

public protocol Spider {
    init(url: ScrappableURL)
    
    func request(completion: @escaping (Data?, URLResponse?, Error?) -> Void)
}

/// Class, managing scrapping logic. Maintain strong reference to object of this class while scrapping is in progress.
open class Swarm {
    
    /// Queue of urls waiting to be scrapped
    internal var scrapQueue: [ScrappableURL]
    
    /// Currently working spiders and urls they are sent to scrap
    internal var spiders: [ScrappableURL: Spider] = [:]
    
    /// Action log for urls, that are currently being scraped
    internal var actionLog: [ScrappableURL: [ResponseAnalyzer.Action]] = [:]
    
    /// Number of yet - uncalled callbacks from `scrappedURL(_:nextScrappableURLs:)` method. Until this number reaches 0, and until scrapQueue contains items, scrapping will not be considered completed.
    internal var waitingForPageParsingResultsCount: Int = 0
    
    /// Log of all urls, that have been passed as starting, as well as urls that were added later. This property is used to ensure uniqueness of each URL that is about to be scraped.
    internal var scrappedLog: Set<ScrappableURL> = .init()
    
    /// Configuration object
    let configuration : SwarmConfiguration
    
    /// Delegate for `Swarm`.
    weak var delegate: SwarmDelegate?
    
    /// Date, when scrapping was started
    private var startDate: Date?
    
    /// Date, when scrapping ended
    private var endDate: Date?
    
    /// Time between `endDate` and `startDate` in seconds. If scrapping was not started, this property returns nil.
    public var scrappingDuration: TimeInterval? {
        guard let start = startDate else {
            return nil
        }
        return (endDate ?? Date()).timeIntervalSince1970 - start.timeIntervalSince1970
    }
    
    /// Object deciding how to proceed based on response received. For example, should request be retried, and if so, after what delay.
    public var responseAnalyzer: ResponseAnalyzer = .init()
    
    /// Creates `Swarm` object
    /// - Parameters:
    ///   - startURLs: URLs to start scrapping from. Those URL's are assigned with depth 1.
    ///   - configuration: configuration object.
    ///   - delegate: delegate object.
    public init(startURLs: [URL], configuration: SwarmConfiguration = .init(), delegate: SwarmDelegate) {
        self.configuration = configuration
        self.scrapQueue = Array(Set(startURLs)).map { ScrappableURL(url: $0) }
        self.delegate = delegate
    }
    
    /// Start web scrapping.
    public func start() {
        scrapQueue.forEach { scrappedLog.insert($0) }
        startDate = Date()
        endDate = nil
        crawl()
    }
    
    /// Add url to scrapping queue.
    /// - Parameter url: `ScrappableURL` object.
    public func add(_ url: ScrappableURL) {
        let uniqueURLs = Set([url])
        self.scrapQueue.append(contentsOf: uniqueURLs.subtracting(self.scrappedLog))
        uniqueURLs.forEach { self.scrappedLog.insert($0) }
    }
    
    func crawl() {
        if scrapQueue.count == 0, waitingForPageParsingResultsCount == 0, spiders.keys.count == 0 {
            endDate = Date()
            delegate?.scrappingCompleted()
            return
        }
        guard spiders.keys.count < configuration.maxConcurrentConnections else { return }
        for _ in 0..<(configuration.maxConcurrentConnections - spiders.keys.count) {
            guard let scrapUrl = takeNextURL() else {
                return
            }
            guard let spider = delegate?.spider(for: scrapUrl) else {
                return
            }
            spiders[scrapUrl] = spider
            spider.request { [weak self] data, response, error in
                self?.receivedSpiderResponse(VisitedURL(origin: scrapUrl,
                                                        data: data,
                                                        response: response,
                                                        error: error),
                                             spider: spider)
            }
        }
    }
    
    func takeNextURL() -> ScrappableURL? {
        switch configuration.scrappingBehavior {
            case .anyOrder: return scrapQueue.popLast()
            case .depthFirst:
                guard let maxDepth = scrapQueue.enumerated().max(by: { first, second in
                    first.element.depth < second.element.depth
                }) else { return nil }
                scrapQueue.remove(at: maxDepth.offset)
                return maxDepth.element
            case .breadthFirst:
                guard let minDepth = scrapQueue.enumerated().min(by: { first, second in
                    first.element.depth < second.element.depth
                }) else { return nil }
                scrapQueue.remove(at: minDepth.offset)
                return minDepth.element
        }
    }
    
    func receivedSpiderResponse(_ url: VisitedURL, spider: Spider) {
        let action = responseAnalyzer.analyzeResponse(url, configuration: configuration, previousActions: actionLog[url.origin] ?? [])
        actionLog[url.origin]?.append(action)
        switch action {
            case .failure: processFailure(url)
            case .success: processSuccess(url)
            case .repeatRequest(after: let interval):
                delegate?.delayingRequest(to: url.origin, for: interval, becauseOf: url.response)
                repeatRequest(url: url.origin, spider: spider, afterDelay: interval)
        }
    }
    
    func repeatRequest(url: ScrappableURL, spider: Spider, afterDelay delay: TimeInterval) {
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) { [weak self] in
            spider.request { data, response, error in
                self?.receivedSpiderResponse(VisitedURL(origin: url,
                                                        data: data,
                                                        response: response,
                                                        error: error),
                                             spider: spider)
            }
        }
    }
    
    func processSuccess(_ url: VisitedURL) {
        waitingForPageParsingResultsCount += 1
        delegate?.scrappedURL(url, nextScrappableURLs: { [weak self] nextURLs in
            guard let self = self else { return }
            let uniqueURLs = Set(nextURLs)
            self.scrapQueue.append(contentsOf: uniqueURLs.subtracting(self.scrappedLog))
            uniqueURLs.forEach { self.scrappedLog.insert($0) }
            self.waitingForPageParsingResultsCount -= 1
            self.proceed(afterCleanupForURL: url.origin)
        })
    }
    
    func processFailure(_ url: VisitedURL) {
        delegate?.failedToScrapURL(url)
        proceed(afterCleanupForURL: url.origin)
    }
    
    func proceed(afterCleanupForURL url: ScrappableURL) {
        // Check if there are any available spiders, that are not on cooldown
        crawl()
        
        // Current spider is on cooldown, continue after configuration.downloadDelay
        DispatchQueue.main.asyncAfter(deadline: .now() + configuration.downloadDelay) { [weak self] in
            self?.scrappedLog.insert(url)
            self?.spiders.removeValue(forKey: url)
            self?.actionLog.removeValue(forKey: url)
            self?.crawl()
        }
    }
}
