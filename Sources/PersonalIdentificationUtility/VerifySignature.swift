//
//  VerifySignature.swift
//  personal-identification
//
//  Created by Arkivili Collindort on 29/12/2025
//

import ArgumentParser
import Foundation
import PersonalIdentification

struct VerifySignature: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "signature",
        abstract: "Verify the signature of a MRZ code."
    )
    
    @Argument(help: "MRZ Line 1")
    var line1: String
    
    @Argument(help: "MRZ Line 2")
    var line2: String?
    
    @Option(name: [.long, .short], help: "Signature of provided MRZ code.")
    var signature: Data
    
    @Option(name: [.long, .customShort("k")], help: "Public key.")
    var publicKey: Data
    
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
            line1: line1,
            line2: line2,
            showAlert: alert,
            caseInsensitive: caseInsensitive
        )
        
        let publicKey = try PINPublicKey(rawRepresentation: publicKey)
        
        let result = try info.verifySignature(signature, with: publicKey)
        
        print("Signature is \(result ? "valid" : "invalid").")
    }
}
