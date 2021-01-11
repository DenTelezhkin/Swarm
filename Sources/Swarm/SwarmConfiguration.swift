//
//  SwarmConfiguration.swift
//  
//
//  Created by Denys Telezhkin on 04.01.2021.
//

import Foundation

public enum ScrappingBehavior {
    case depthFirst
    case breadthFirst
    case anyOrder
}

public struct SwarmConfiguration {
    public init(successStatusCodes: [Int] = [200],
                  delayedRetryStatusCodes: [Int] = [202],
                  delayedRetryDelay: TimeInterval = 5.0,
                  delayedRequestRetries: Int = 2,
                  autoThrottleHTTPStatusCodes: [Int] = [500, 502, 503, 504, 522, 524, 408, 429],
                  maxAutoThrottleDelay: TimeInterval = 30.0,
                  autoThrottleRequestRetries: Int = 2,
                  downloadDelay: TimeInterval = 1.0,
                  maxConcurrentConnections: Int = 8,
                  scrappingBehavior : ScrappingBehavior = .anyOrder) {
        self.successStatusCodes = successStatusCodes
        self.delayedRetryStatusCodes = delayedRetryStatusCodes
        self.delayedRetryDelay = delayedRetryDelay
        self.delayedRequestRetries = delayedRequestRetries
        self.autoThrottleHTTPStatusCodes = autoThrottleHTTPStatusCodes
        self.maxAutoThrottleDelay = maxAutoThrottleDelay
        self.autoThrottleRequestRetries = autoThrottleRequestRetries
        self.downloadDelay = downloadDelay
        self.maxConcurrentConnections = maxConcurrentConnections
        self.scrappingBehavior = scrappingBehavior
    }
    var successStatusCodes : [Int]
    
    var delayedRetryStatusCodes: [Int]
    
    var delayedRetryDelay : TimeInterval
    
    var delayedRequestRetries: Int
    
    var autoThrottleHTTPStatusCodes: [Int]
    
    var maxAutoThrottleDelay: TimeInterval
    
    var autoThrottleRequestRetries: Int
    
    var downloadDelay: TimeInterval
    
    var maxConcurrentConnections: Int
    
    var scrappingBehavior: ScrappingBehavior
}
