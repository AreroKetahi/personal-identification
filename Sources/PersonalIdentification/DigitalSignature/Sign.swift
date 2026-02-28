//
//  Sign.swift
//  personal-identification
//
//  Created by Arkivili Collindort on 24/12/2025
//

import Foundation
import SwiftProtobuf
import Crypto

extension PersonalInformation {
    /// Sign information.
    /// - Parameter privateKey: Issuer's private key.
    /// - Returns: Digital signature of this personal information.
    @inlinable
    public func sign(with privateKey: PINPrivateKey) throws -> Data {
        let bearer = self.protobufRepresentation
        
        // create plain data
        let data = try bearer.serializedData()
        
        // sign data
        return try privateKey.signature(for: data)
    }
    
    /// Sign a known MRZ code.
    /// - Parameters:
    ///   - mrz: MRZ code, in jointly or separated as newline.
    ///   - privateKey: Issuer's private key.
    /// - Returns: Digital signature of specified personal information.
    @inlinable
    public static func sign(_ mrz: String, with privateKey: PINPrivateKey) throws -> Data {
        let info = try PersonalInformation(mrzString: mrz)
        return try info.sign(with: privateKey)
    }
    
    
    /// Sign a known MRZ code in separate.
    /// - Parameters:
    ///   - line1: MRZ code line 1.
    ///   - line2: MRZ code line 2.
    ///   - privateKey: Issuer's private key.
    /// - Returns: Digital signature of specified personal information.
    @inlinable
    public static func sign(line1: String, line2: String, with privateKey: PINPrivateKey) throws -> Data {
        let info = try PersonalInformation(line1: line1, line2: line2)
        return try info.sign(with: privateKey)
    }
    
    @inlinable
    package func standaredToSignature(_ string: String) -> String {
        return string.uppercased().replacingOccurrences(of: " ", with: "<")
    }
}
