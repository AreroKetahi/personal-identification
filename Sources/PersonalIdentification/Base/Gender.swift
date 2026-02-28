//
//  Gender.swift
//  personal-identification
//
//  Created by Arkivili Collindort on 24/12/2025
//

import Foundation

/// Gender Implementation that supports *Personal Identification Guideline*.
public enum Gender: Sendable, Codable {
    /// Male, represent as "M".
    case male
    /// Female, represent as "F".
    case female
    /// Other, represent as "O".
    case other
    /// Prefer Not to Say, represent as "P".
    case preferNotToSay
    /// Unknown gender identifier.
    case unknown(String)
}

extension Gender: RawRepresentable, CaseIterable {
    public init?(rawValue: String) {
        guard rawValue.count == 1 else { return nil }

        switch rawValue.uppercased() {
        case "M": self = .male
        case "F": self = .female
        case "O": self = .other
        case "P": self = .preferNotToSay
        default: self = .unknown(rawValue)
        }
    }

    public var rawValue: String {
        switch self {
        case .male: return "M"
        case .female: return "F"
        case .other: return "O"
        case .preferNotToSay: return "P"
        case .unknown(let value): return value
        }
    }

    public static let allCases: [Gender] = [
        .male, .female, .other, .preferNotToSay,
    ]
}
