//
//  Sign.swift
//  personal-identification
//
//  Created by Arkivili Collindort on 28/12/2025
//

import ArgumentParser
import Foundation
import PersonalIdentification

struct Sign: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "sign",
        abstract: "Sign MRZ."
    )
    
    @Argument(help: "MRZ Line 1")
    var line1: String
    
    @Argument(help: "MRZ Line 2")
    var line2: String?
    
    @Option(name: [.long, .customShort("k")], help: "Private key.")
    var privateKey: Data
    
    @Flag(name: [.long, .short], help: "Show alert")
    var alert: Bool = false
    
    @Flag(
        name: [.long],
        help: "Ignore input cases, and port it to upper case."
    ) var caseInsensitive: Bool = false
    
    @Flag(help: "Output format.")
    var outputFormat: DataOutputFormat = .base64
        
    
    func run() throws {
        let info = try PIUExtractInformationFrom(
            line1: line1, line2: line2,
            showAlert: alert,
            caseInsensitive: caseInsensitive
        )
        
        let key = try PINPrivateKey(rawRepresentation: privateKey)
        let signature = try info.sign(with: key)
        
        switch outputFormat {
        case .hex:
            print(signature.hexadecimalEncodedString)
        case .base64:
            print(signature.base64EncodedString())
        case .base36:
            print(signature.base36EncodedString)
        }
    }
}
