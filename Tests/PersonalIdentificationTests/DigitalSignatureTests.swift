//
//  DigitalSignatureTests.swift
//  personal-identification
//
//  Created by Arkivili Collindort on 04/03/2026
//

import Testing
import Foundation
@testable import PersonalIdentification

private func makePersonalInformation(
    givenName: String = "John",
    familyName: String = "Doe",
    departmentID: String = "DPT"
) throws -> PersonalInformation {
    return try PersonalInformation(
        givenName: givenName,
        familyName: familyName,
        nationality: "ZZZ",
        gender: .male,
        dateOfBirth: Date("31/12/1999", strategy: .dateTime.year().month().day()),
        personalID: "PERSID",
        cardID: "MYCARD",
        departmentID: departmentID,
        validDate: Date("01/01/2050", strategy: .dateTime.year().month().day())
    )
}

@Test("Digital signature sign/verify for PersonalInformation")
func digitalSignatureSignVerifyForPersonalInformation() async throws {
    let info = try makePersonalInformation()
    let privateKey = PINPrivateKey()
    let publicKey = privateKey.publicKey

    let signature = try info.sign(with: privateKey)
    let verified = try info.verifySignature(signature, with: publicKey)

    #expect(verified)
}

@Test("Digital signature sign/verify for MRZ string and lines")
func digitalSignatureSignVerifyForMrzStringAndLines() async throws {
    let info = try makePersonalInformation(givenName: "Jane", familyName: "Smith")
    let privateKey = PINPrivateKey()
    let publicKey = privateKey.publicKey

    let mrz = info.createMRZCode()
    let lines = mrz.split(separator: "\n").map(String.init)

    let signatureFromMrz = try PersonalInformation.sign(mrz, with: privateKey)
    let verifiedMrz = try PersonalInformation.verifySignature(signatureFromMrz, for: mrz, with: publicKey)

    let signatureFromLines = try PersonalInformation.sign(line1: lines[0], line2: lines[1], with: privateKey)
    let verifiedLines = try PersonalInformation.verifySignature(
        signatureFromLines,
        line1: lines[0],
        line2: lines[1],
        with: publicKey
    )

    #expect(verifiedMrz)
    #expect(verifiedLines)
}

@Test("Digital signature verification fails with wrong public key")
func digitalSignatureVerificationFailsWithWrongPublicKey() async throws {
    let info = try makePersonalInformation()
    let privateKey = PINPrivateKey()
    let wrongPublicKey = PINPrivateKey().publicKey

    let signature = try info.sign(with: privateKey)
    let verified = try info.verifySignature(signature, with: wrongPublicKey)

    #expect(!verified)
}

@Test("Digital signature verification fails with modified MRZ")
func digitalSignatureVerificationFailsWithModifiedMrz() async throws {
    let info = try makePersonalInformation(givenName: "Alice", familyName: "Wong")
    let privateKey = PINPrivateKey()
    let publicKey = privateKey.publicKey

    let mrz = info.createMRZCode()
    let signature = try PersonalInformation.sign(mrz, with: privateKey)

    let tamperedLine1 = "DPT<DOE<<JOHN".padding(toLength: 37, withPad: "<", startingAt: 0)
    let line2 = mrz.split(separator: "\n").map(String.init)[1]
    let tamperedMrz = "\(tamperedLine1)\n\(line2)"

    let verified = try PersonalInformation.verifySignature(signature, for: tamperedMrz, with: publicKey)

    #expect(!verified)
}
