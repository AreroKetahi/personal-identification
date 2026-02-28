//
//  ColorSign.swift
//  personal-identification
//
//  Created by Arkivili Collindort on 21/01/2026
//

import ArgumentParser
import Foundation
import PersonalIdentification

struct ColorSign: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "color-sign",
        abstract: "Sign MRZ by using color."
    )
    
    @Argument(help: "MRZ Line 1")
    var line1: String
    
    @Argument(help: "MRZ Line 2")
    var line2: String?
    
    @Flag(name: [.long, .short], help: "Show alert")
    var alert: Bool = false
    
    @Flag(
        name: [.long],
        help: "Ignore input cases, and port it to upper case."
    ) var caseInsensitive: Bool = false
    
    
    func run() throws {
        let info = try PIUExtractInformationFrom(
            line1: line1, line2: line2,
            showAlert: alert,
            caseInsensitive: caseInsensitive
        )
        
        let (signature, correction) = info.colorSignatureWithCorrectionCode()
        
        print(
            """
            Signature:  \(signature.map { String($0.rawValue) }.joined())
            Correction: \(correction.map { String($0.rawValue) }.joined())
            """
        )
    }
}
