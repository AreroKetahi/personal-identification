//
//  ColorSignatureTests.swift
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
    personalID: String = "PERSID",
    cardID: String = "MYCARD",
    departmentID: String = "DPT"
) throws -> PersonalInformation {
    return try PersonalInformation(
        givenName: givenName,
        familyName: familyName,
        nationality: "ZZZ",
        gender: .female,
        dateOfBirth: Date("31/12/1999", strategy: .dateTime.year().month().day()),
        personalID: personalID,
        cardID: cardID,
        departmentID: departmentID,
        validDate: Date("01/01/2050", strategy: .dateTime.year().month().day())
    )
}

@Test("Color signature has fixed length and valid ranges")
func colorSignatureHasFixedLengthAndValidRanges() async throws {
    let info = try makePersonalInformation()
    let signature = info.colorSignature()

    #expect(signature.count == 24)
    #expect(signature.allSatisfy { $0.rawValue <= 7 })
}

@Test("Color signature is deterministic for the same input")
func colorSignatureIsDeterministicForSameInput() async throws {
    let info = try makePersonalInformation()
    let signature1 = info.colorSignature()
    let signature2 = info.colorSignature()

    #expect(signature1 == signature2)
}

@Test("Color signature changes when MRZ changes")
func colorSignatureChangesWhenMrzChanges() async throws {
    let infoA = try makePersonalInformation(givenName: "Alice")
    let infoB = try makePersonalInformation(givenName: "Bob")

    let signatureA = infoA.colorSignature()
    let signatureB = infoB.colorSignature()

    #expect(signatureA != signatureB)
}

@Test("Color correction length and RS parity match")
func colorCorrectionLengthAndParityMatch() async throws {
    let info = try makePersonalInformation()
    let (signature, correction) = info.colorSignatureWithCorrectionCode()

    #expect(signature.count == 24)
    #expect(correction.count == 16)

    let segments: [(range: Range<Int>, parity: Int)] = [
        (0..<5, 3),
        (5..<10, 3),
        (10..<15, 3),
        (15..<20, 3),
        (20..<24, 4)
    ]

    var correctionIndex = 0
    for segment in segments {
        let dataSymbols = signature[segment.range].map { $0.rawValue }
        let paritySymbols = rsEncodeGF8(data: dataSymbols, parity: segment.parity)
        let expected = paritySymbols.map { CodeColor(rawValue: $0)! }
        let actual = Array(correction[correctionIndex..<(correctionIndex + segment.parity)])
        #expect(expected == actual)
        correctionIndex += segment.parity
    }
}

@Test("Color correction changes when a data symbol changes")
func colorCorrectionChangesWhenDataSymbolChanges() async throws {
    let info = try makePersonalInformation()
    let (signature, correction) = info.colorSignatureWithCorrectionCode()

    var tampered = signature
    tampered[0] = tampered[0] == .white ? .black : .white

    let segments: [(range: Range<Int>, parity: Int)] = [
        (0..<5, 3),
        (5..<10, 3),
        (10..<15, 3),
        (15..<20, 3),
        (20..<24, 4)
    ]

    var recomputed: [CodeColor] = []
    for segment in segments {
        let dataSymbols = tampered[segment.range].map { $0.rawValue }
        let paritySymbols = rsEncodeGF8(data: dataSymbols, parity: segment.parity)
        recomputed.append(contentsOf: paritySymbols.map { CodeColor(rawValue: $0)! })
    }

    #expect(recomputed != correction)
}

@Test("Color correction fixes up to two errors in the last segment")
func colorCorrectionFixesUpToTwoErrorsInLastSegment() async throws {
    let info = try makePersonalInformation(givenName: "Eve", familyName: "Holt")
    let (signature, correction) = info.colorSignatureWithCorrectionCode()

    var tamperedSignature = signature
    tamperedSignature[20] = tamperedSignature[20] == .white ? .black : .white
    tamperedSignature[23] = tamperedSignature[23] == .white ? .black : .white

    let result = try PersonalInformation.correctColorSignature(
        signature: tamperedSignature,
        correction: correction
    )

    #expect(result.correctedSignature == signature)
    #expect(result.correctedSymbolCount == 2)
}

@Test("Color correction recovers missing symbols passed as nil")
func colorCorrectionRecoversMissingSymbols() async throws {
    let info = try makePersonalInformation(givenName: "Eve", familyName: "Holt")
    let (signature, correction) = info.colorSignatureWithCorrectionCode()
    var packed: [CodeColor?] = (signature + correction).map { Optional($0) }

    packed[20] = nil
    packed[23] = nil

    let result = try PersonalInformation.correctColorSignature(packed: packed)

    #expect(result.correctedSignature == signature)
    #expect(result.correctedSymbolCount == 2)
}
