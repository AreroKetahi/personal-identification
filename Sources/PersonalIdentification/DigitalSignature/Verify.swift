//
//  Verify.swift
//  personal-identification
//
//  Created by Arkivili Collindort on 28/12/2025
//

import Crypto
import Foundation
import SwiftProtobuf

extension PersonalInformation {
    /// Verify signature for current information.
    /// - Parameters:
    ///   - signature: Signature of current information.
    ///   - publicKey: Signature related public key.
    /// - Returns: Verification result, `true` for verified, otherwise `false`.
    @inlinable
    public func verifySignature(
        _ signature: Data,
        with publicKey: PINPublicKey
    ) throws -> Bool
    {
        let bearer = self.protobufRepresentation

        let data = try bearer.serializedData()

        return publicKey.isValidSignature(signature, for: data)
    }
    
    /// Verify signature for known MRZ string.
    /// - Parameters:
    ///   - signature: Signature for specified MRZ code.
    ///   - mrz: MRZ code, jointly or separated with newline.
    ///   - publicKey: Signature related public key.
    /// - Returns: Verification result, `true` for verified, otherwise `false`.
    @inlinable
    public static func verifySignature(
        _ signature: Data,
        for mrz: String,
        with publicKey: PINPublicKey
    ) throws -> Bool {
        let info = try PersonalInformation(mrzString: mrz)
        return try info.verifySignature(signature, with: publicKey)
    }
    
    /// Verify signature for known MRZ string in separate.
    /// - Parameters:
    ///   - signature: Signature for specified MRZ code.
    ///   - line1: MRZ code line 1.
    ///   - line2: MRZ code line 2.
    ///   - publicKey: Signature related public key.
    /// - Returns: Verification result, `true` for verified, otherwise `false`.
    @inlinable
    public static func verifySignature(
        _ signature: Data,
        line1: String,
        line2: String,
        with publicKey: PINPublicKey
    ) throws -> Bool {
        let info = try PersonalInformation(line1: line1, line2: line2)
        return try info.verifySignature(signature, with: publicKey)
    }
}
