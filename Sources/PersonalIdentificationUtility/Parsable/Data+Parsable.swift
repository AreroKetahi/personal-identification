//
//  Data+Parsable.swift
//  personal-identification
//
//  Created by Arkivili Collindort on 28/12/2025
//

import ArgumentParser
import Foundation

extension Data: @retroactive ExpressibleByArgument {
    public init?(argument: String) {
        if let data = Data(hexadecimalEncoded: argument) {
            self = data
        } else if let data = Data(base36Encoded: argument) {
            self = data
        } else if let data = Data(base64Encoded: argument) {
            self = data
        } else {
            return nil
        }
    }
}
