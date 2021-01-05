import Foundation

public protocol Spider {
    init(url: ScrappableURL)
    
    func request(completion: @escaping (Data?, URLResponse?, Error?) -> Void)
}

open class Swarm {
    
    internal var scrapQueue: [ScrappableURL]

    internal var spiders: [ScrappableURL: Spider] = [:]
    
    internal var actionLog: [ScrappableURL: [ResponseAnalyzer.Action]] = [:]
    
    internal var waitingForPageParsingResultsCount: Int = 0
    
    internal var scrappedLog: Set<ScrappableURL> = .init()
    
    let configuration : SwarmConfiguration
    
    weak var delegate: SwarmDelegate?
    
    private var startDate: Date?
    private var endDate: Date?
    
    public var scrappingDuration: TimeInterval? {
        guard let start = startDate else {
            return nil
        }
        return (endDate ?? Date()).timeIntervalSince1970 - start.timeIntervalSince1970
    }
    
    public var responseAnalyzer: ResponseAnalyzer = .init()
    
    public init(startURLs: [URL], configuration: SwarmConfiguration = .init(), delegate: SwarmDelegate) {
        self.configuration = configuration
        self.scrapQueue = Array(Set(startURLs)).map { ScrappableURL(url: $0) }
        self.delegate = delegate
    }
    
    public func start() {
        scrapQueue.forEach { scrappedLog.insert($0) }
        startDate = Date()
        endDate = nil
        crawl()
    }
    
    public func addURL(_ url: ScrappableURL) {
        scrapQueue.append(url)
    }
    
    func crawl() {
        if scrapQueue.count == 0, waitingForPageParsingResultsCount == 0, spiders.keys.count == 0 {
            endDate = Date()
            delegate?.scrappingCompleted()
            return
        }
        guard spiders.keys.count < configuration.maxConcurrentConnections else { return }
        for _ in 0..<(configuration.maxConcurrentConnections - spiders.keys.count) {
            guard let scrapUrl = scrapQueue.popLast() else {
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
