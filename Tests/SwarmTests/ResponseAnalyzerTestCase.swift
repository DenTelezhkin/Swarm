import XCTest
@testable import Swarm

final class ResponseAnalyzerTestCase: XCTestCase {
    
    var configuration: SwarmConfiguration = .init()
    
    func url(statusCode: Int, headers: [String:String], error: Error? = nil) -> VisitedURL {
        VisitedURL(origin: .init(url: URL(fileURLWithPath: "")), data: Data(), response: HTTPURLResponse(url: URL(fileURLWithPath: ""), statusCode: statusCode, httpVersion: "HTTP/1.1", headerFields: headers), error: error)
    }
    
    func test200IsProducingSuccess() {
        let result = ResponseAnalyzer().analyzeResponse(url(statusCode: 200, headers: [:]), configuration: .init(), previousActions: [])
        
        XCTAssertEqual(result, .success)
    }
    
    func test202IsRepeatedAfterDelay() {
        let result = ResponseAnalyzer().analyzeResponse(url(statusCode: 202, headers: [:]), configuration: .init(), previousActions: [])
        
        XCTAssertEqual(result, .repeatRequest(after: configuration.delayedRetryDelay))
    }
    
    func testDelayedRequestsAreOnlyRetriedTwoTimes() {
        let result = ResponseAnalyzer().analyzeResponse(url(statusCode: 202, headers: [:]), configuration: configuration, previousActions: [.repeatRequest(after: 5), .repeatRequest(after: 5)])
        
        XCTAssertEqual(result, .failure)
    }
    
    func testRequestIsThrottledWhenReceivingOneOfThrottleStatusCodes() {
        let result = ResponseAnalyzer().analyzeResponse(url(statusCode: 429, headers: [:]), configuration: configuration, previousActions: [])
        
        XCTAssertEqual(result, .repeatRequest(after: configuration.maxAutoThrottleDelay))
    }
    
    func testRequestIsThrottledMaximumTwoTimes() {
        let result = ResponseAnalyzer().analyzeResponse(url(statusCode: 429, headers: [:]), configuration: configuration, previousActions: [.repeatRequest(after: 30), .repeatRequest(after: 30)])
        
        XCTAssertEqual(result, .failure)
    }
    
    func testThrottlingRespectsRetryAfterHeader() {
        let result = ResponseAnalyzer().analyzeResponse(url(statusCode: 429, headers: ["Retry-After":"15"]), configuration: configuration, previousActions: [])
        
        XCTAssertEqual(result, .repeatRequest(after: 15))
    }
    
    func testThrottlingDoesNotGoOverThrottlingLimit() {
        let result = ResponseAnalyzer().analyzeResponse(url(statusCode: 429, headers: ["Retry-After":"45"]), configuration: configuration, previousActions: [])
        
        XCTAssertEqual(result, .repeatRequest(after: 30))
    }
    
    func testOtherHTTPCodesFailImmediately() {
        let result = ResponseAnalyzer().analyzeResponse(url(statusCode: 404, headers: [:]), configuration: configuration, previousActions: [])
        
        XCTAssertEqual(result, .failure)
    }
}
