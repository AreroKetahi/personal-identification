//
//  MRZTests.swift
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
    nationality: String = "ZZZ",
    gender: Gender = .male,
    personalID: String = "PERSID",
    cardID: String = "MYCARD",
    departmentID: String = "DPT"
) throws -> PersonalInformation {
    return try PersonalInformation(
        givenName: givenName,
        familyName: familyName,
        nationality: nationality,
        gender: gender,
        dateOfBirth: Date("31/12/1999", strategy: .dateTime.year().month().day()),
        personalID: personalID,
        cardID: cardID,
        departmentID: departmentID,
        validDate: Date("01/01/2050", strategy: .dateTime.year().month().day())
    )
}

private func replaceCharacter(
    in string: String,
    at index: Int,
    with newValue: Character
) -> String {
    var characters = Array(string)
    characters[index] = newValue
    return String(characters)
}

private func expectPersonalInformationError(
    _ matches: (PersonalInformationError) -> Bool,
    operation: () throws -> Void
) {
    #expect(throws: PersonalInformationError.self) {
        do {
            try operation()
        } catch let error as PersonalInformationError {
            if matches(error) {
                throw error
            }
            return
        } catch {
            throw error
        }
    }
}

@Test("MRZ round-trip via line1 + line2")
func mrzRoundTripViaLines() async throws {
    let original = try makePersonalInformation(givenName: "John Albert", familyName: "Doe")
    let line1 = original.createMRZLine1Code()
    let line2 = original.createMRZLine2Code()

    let parsed = try PersonalInformation(line1: line1, line2: line2)

    #expect(parsed.givenName == original.givenName)
    #expect(parsed.familyName == original.familyName)
    #expect(parsed.personalID == original.personalID)
    #expect(parsed.cardID == original.cardID)
    #expect(parsed.nationality == original.nationality)
    #expect(Calendar.current.isDate(parsed.dateOfBirth, inSameDayAs: original.dateOfBirth))
    #expect(Calendar.current.isDate(parsed.validDate, inSameDayAs: original.validDate))
    #expect(parsed.gender == original.gender)
}

@Test("MRZ parsing from combined string with newline")
func mrzParsingFromCombinedStringWithNewline() async throws {
    let original = try makePersonalInformation(givenName: "Amy", familyName: "Wong")
    let mrz = original.createMRZCode()

    let parsed = try PersonalInformation(mrzString: mrz)

    #expect(parsed.givenName == original.givenName)
    #expect(parsed.familyName == original.familyName)
}

@Test("MRZ parsing from combined string without newline")
func mrzParsingFromCombinedStringWithoutNewline() async throws {
    let original = try makePersonalInformation(givenName: "Amy", familyName: "Wong")
    let line1 = original.createMRZLine1Code()
    let line2 = original.createMRZLine2Code()
    let mrz = line1 + line2

    let parsed = try PersonalInformation(mrzString: mrz)

    #expect(parsed.givenName == original.givenName)
    #expect(parsed.familyName == original.familyName)
}

@Test("MRZ parsing fails for invalid total length")
func mrzParsingFailsForInvalidTotalLength() async throws {
    let mrz = "ABC"

    expectPersonalInformationError({ error in
        if case .invalidTotalLength = error { return true }
        return false
    }, operation: {
        _ = try PersonalInformation(mrzString: mrz)
    })
}

@Test("MRZ parsing fails for invalid character in line1")
func mrzParsingFailsForInvalidCharacterInLine1() async throws {
    let info = try makePersonalInformation()
    let line1 = info.createMRZLine1Code().replacingOccurrences(of: "DOE", with: "DO\u{00E9}")
    let line2 = info.createMRZLine2Code()
    let mrz = "\(line1)\n\(line2)"

    expectPersonalInformationError({ error in
        if case .invalidCharacter = error { return true }
        return false
    }, operation: {
        _ = try PersonalInformation(mrzString: mrz)
    })
}

@Test("MRZ parsing fails when name separator is missing")
func mrzParsingFailsWhenNameSeparatorMissing() async throws {
    let line1 = "DPT<DOE<JOHN".padding(toLength: 37, withPad: "<", startingAt: 0)
    let line2 = try makePersonalInformation().createMRZLine2Code()

    #expect(throws: PersonalInformationError.self) {
        _ = try PersonalInformation(line1: line1, line2: line2)
    }
}

@Test("MRZ parsing fails when name field is missing")
func mrzParsingFailsWhenNameFieldMissing() async throws {
    let line1 = "DPTJOHNDOE".padding(toLength: 37, withPad: "<", startingAt: 0)
    let line2 = try makePersonalInformation().createMRZLine2Code()

    #expect(throws: PersonalInformationError.self) {
        _ = try PersonalInformation(line1: line1, line2: line2)
    }
}

@Test("MRZ parsing fails when cardID check digit is invalid")
func mrzParsingFailsWhenCardIDCheckDigitInvalid() async throws {
    let info = try makePersonalInformation()
    let line1 = info.createMRZLine1Code()
    let line2 = info.createMRZLine2Code()

    let checkIndex = 8
    let current = Array(line2)[checkIndex]
    let replacement: Character = current == "0" ? "1" : "0"
    let tamperedLine2 = replaceCharacter(in: line2, at: checkIndex, with: replacement)

    expectPersonalInformationError({ error in
        if case .veriCodeUnvalidated(let type, _) = error {
            return type == .cardID
        }
        return false
    }, operation: {
        _ = try PersonalInformation(line1: line1, line2: tamperedLine2)
    })
}

@Test("MRZ parsing maps unknown gender to .unknown")
func mrzParsingMapsUnknownGenderToOther() async throws {
    let info = try makePersonalInformation()
    let line1 = info.createMRZLine1Code()
    let line2 = info.createMRZLine2Code()

    let genderIndex = 19
    let tamperedLine2 = replaceCharacter(in: line2, at: genderIndex, with: "X")

    let parsed = try PersonalInformation(line1: line1, line2: tamperedLine2, validEnforcement: false)

    #expect(parsed.gender == .unknown("X"))
}
