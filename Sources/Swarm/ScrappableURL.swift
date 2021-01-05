import Foundation

public struct ScrappableURL: Hashable {
    public let depth: Int
    public let url : URL
    
    public init(url: URL, depth: Int = 1) {
        self.depth = depth
        self.url = url
    }
}

public struct VisitedURL {
    public let origin: ScrappableURL
    
    public func htmlString(using encoding: String.Encoding = .utf8) -> String? {
        guard let data = data else { return nil }
        return String(data: data, encoding: encoding)
    }
    
    public let data: Data?
    public let response: URLResponse?
    public let error: Error?
}
