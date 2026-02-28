//
//  Gender+Parsable.swift
//  personal-identification
//
//  Created by Arkivili Collindort on 25/12/2025
//

import ArgumentParser
import PersonalIdentification

extension Gender: ExpressibleByArgument {
    public static let allValueStrings: [String] = [
        "male", "female", "other", "preferredNotToSay",
    ]

    public static let defaultCompletionKind: CompletionKind = .list([
        "male", "female", "other", "preferredNotToSay",
    ])

    public init?(argument: String) {
        switch argument {
        case "m", "male": self = .male
        case "f", "female": self = .female
        case "o", "other": self = .other
        case "p", "preferredNotToSay": self = .preferNotToSay
        default: return nil
        }
    }
}
