//
//  UserAgent.swift
//  
//
//  Created by Denys Telezhkin on 04.01.2021.
//

import Foundation

public enum UserAgent {
    case none
    case `static`(String)
    case randomized([String])
    
    var value: String? {
        switch self {
            case .none: return nil
            case .static(let value): return value
            case .randomized(let values): return values.randomElement()
        }
    }
}
