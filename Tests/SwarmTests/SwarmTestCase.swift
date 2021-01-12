import XCTest
@testable import Swarm

struct MockError: Error {}

class MockSwarmDelegate : SwarmDelegate {
    
    var mockSpiderConfiguration : (MockSpider) -> () = { _ in }
    
    var scrapCompleted : () -> () = {}
    func scrappingCompleted() {
        scrapCompleted()
    }
    
    var failedToScrap : (VisitedURL) -> () = { _ in }
    func failedToScrapURL(_ url: VisitedURL) {
        failedToScrap(url)
    }
    
    func spider(for url: ScrappableURL) -> Spider {
        let spider = MockSpider(url: url)
        mockSpiderConfiguration(spider)
        return spider
    }
    
    var nextURLs: (VisitedURL) -> [ScrappableURL] = { _ in [] }
    func scrappedURL(_ url: VisitedURL, nextScrappableURLs: @escaping ([ScrappableURL]) -> Void) {
        nextScrappableURLs(nextURLs(url))
    }
    
    var delayedRequest: (ScrappableURL, TimeInterval, URLResponse?) -> Void = { _,_,_ in }
    func delayingRequest(to url: ScrappableURL, for timeInterval: TimeInterval, becauseOf response: URLResponse?) {
        delayedRequest(url,timeInterval,response)
    }
}

final class SwarmTestCase: XCTestCase {
    
    var mockDelegate : MockSwarmDelegate!
    var swarm : Swarm?
    override func setUpWithError() throws {
        mockDelegate = MockSwarmDelegate()
    }
    
    var mockURLS: [URL] {
        [
            URL(string: "https://www.google.com"),
            URL(string: "https://www.apple.com")
        ].compactMap { $0 }
    }
    
    func testScrappingCompletedIsReported() {
        let exp = expectation(description: "completed")
        mockDelegate.scrapCompleted = {
            exp.fulfill()
        }
        swarm = Swarm(startURLs: mockURLS, delegate: mockDelegate)
        swarm?.start()
        waitForExpectations(timeout: 1)
    }
    
    func testFailureIsReportedForNonRetryStatusCodes() {
        let failedExp = expectation(description: "failed")
        let completedExp = expectation(description: "completed")
        mockDelegate.failedToScrap = { _ in
            failedExp.fulfill()
        }
        mockDelegate.scrapCompleted = {
            completedExp.fulfill()
        }
        mockDelegate.mockSpiderConfiguration = {
            $0.stubFailure(error: MockError(), statusCode: 404)
        }
        swarm = Swarm(startURLs: mockURLS.dropLast(), delegate: mockDelegate)
        swarm?.start()
        waitForExpectations(timeout: 1)
    }
    
    func testRequestIsRetriedAfterCooldown() {
        let retryExp = expectation(description: "retry")
        let completedExp = expectation(description: "completed")
        mockDelegate.mockSpiderConfiguration = {
            $0.conditionallyStub { spider in
                if spider.requestCount == 1 {
                    spider.stubFailure(error: MockError(), statusCode: 202)
                } else {
                    spider.stubSuccess(statusCode: 200)
                }
            }
        }
        mockDelegate.delayedRequest = { _, interval,_ in
            XCTAssertEqual(interval, 0.5)
            retryExp.fulfill()
        }
        mockDelegate.scrapCompleted = {
            completedExp.fulfill()
        }
        swarm = Swarm(startURLs: mockURLS.dropLast(), configuration: .init(delayedRetryDelay: 0.5, downloadDelay: 0), delegate: mockDelegate)
        swarm?.start()
        waitForExpectations(timeout: 1)
    }
    
    func testDepthFirstLogic() {
        let exp = expectation(description: "Correct order")
        let swarm = Swarm(startURLs: [], configuration: .init(scrappingBehavior: .depthFirst), delegate: mockDelegate)
        mockURLS.enumerated().forEach { swarm.add(.init(url: $0.element, depth: $0.offset)) }
        var index = 1
        mockDelegate.nextURLs = { visited in
            XCTAssertEqual(index, visited.origin.depth)
            index -= 1
            if index == 0 {
                exp.fulfill()
            }
            return []
        }
        swarm.start()
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testBreadthFirstLogic() {
        let exp = expectation(description: "Correct order")
        let swarm = Swarm(startURLs: [], configuration: .init(scrappingBehavior: .breadthFirst), delegate: mockDelegate)
        mockURLS.enumerated().forEach { swarm.add(.init(url: $0.element, depth: $0.offset)) }
        var index = 0
        mockDelegate.nextURLs = { visited in
            XCTAssertEqual(index, visited.origin.depth)
            index += 1
            if index == 2 {
                exp.fulfill()
            }
            return []
        }
        swarm.start()
        waitForExpectations(timeout: 1, handler: nil)
    }
}
