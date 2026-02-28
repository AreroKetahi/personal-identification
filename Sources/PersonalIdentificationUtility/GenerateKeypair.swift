//
//  GenerateKeypair.swift
//  personal-identification
//
//  Created by Arkivili Collindort on 28/12/2025
//

import ArgumentParser
import PersonalIdentification

struct GenerateKeypair: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "keypair",
        abstract: "Generate signing keypair."
    )
    
    @Flag(help: "Output format.")
    var outputFormat: DataOutputFormat = .base64
    
    func run() throws {
        let privateKey = PINPrivateKey()
        let publicKey = privateKey.publicKey
        
        let (stringPrivateKey, stringPublicKey) = switch outputFormat {
        case .hex: (
            privateKey.rawRepresentation.hexadecimalEncodedString,
            publicKey.rawRepresentation.hexadecimalEncodedString
        )
        case .base64: (
            privateKey.rawRepresentation.base64EncodedString(),
            publicKey.rawRepresentation.base64EncodedString()
        )
        case .base36: (
            privateKey.rawRepresentation.base36EncodedString,
            publicKey.rawRepresentation.base36EncodedString
        )
        }
        
        print(
            """
            Private Key: \(stringPrivateKey)
            Public Key:  \(stringPublicKey)
            """
        )
    }
}
