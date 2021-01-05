import Foundation

open class ResponseAnalyzer {
    public enum Action: Equatable {
        case success
        case repeatRequest(after: TimeInterval)
        case failure
        
        var isRetry: Bool {
            switch self {
                case .repeatRequest: return true
                default: return false
            }
        }
    }
    
    open func analyzeResponse(_ response: VisitedURL, configuration: SwarmConfiguration, previousActions: [Action]) -> Action {
        guard let httpResponse = response.response as? HTTPURLResponse else {
            // Non-HTTP response? Cannot analyze that.
            return .success
        }
        switch httpResponse.statusCode {
            case configuration.successStatusCodes: return .success
            case configuration.delayedRetryStatusCodes:
                if previousActions.retryCount() < configuration.delayedRequestRetries {
                    return .repeatRequest(after: configuration.delayedRetryDelay)
                } else {
                    return .failure
                }
            case configuration.autoThrottleHTTPStatusCodes:
                if previousActions.retryCount() < configuration.autoThrottleRequestRetries {
                    if let retryAfter = httpResponse.allHeaderFields["Retry-After"] as? String,
                       let retryAfterValue = TimeInterval(retryAfter) {
                        return .repeatRequest(after: min(retryAfterValue, configuration.maxAutoThrottleDelay))
                    } else {
                        return .repeatRequest(after: configuration.maxAutoThrottleDelay)
                    }
                } else {
                    return .failure
                }
            default: return .failure
        }
    }
}

extension Array where Element == ResponseAnalyzer.Action {
    func retryCount() -> Int {
        filter { $0.isRetry }.count
    }
}

func ~=<T: Equatable>(pattern: [T], value: T) -> Bool {
    pattern.contains(value)
}
