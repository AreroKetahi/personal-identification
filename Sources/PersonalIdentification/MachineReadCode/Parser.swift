//
//  Parser.swift
//  personal-identification
//
//  Created by Arkivili Collindort on 24/12/2025
//

import Foundation

extension PersonalInformation {
    /// Parse personal information from a MRZ string
    /// - Parameters:
    ///   - mrzString: MRZ string, jointly or separate with newline.
    ///   - shouldCheckValidity: Should parser check MRZ's validity, default `true`.
    ///   - shouldShowAlert: Should parser report warning, default `false`.
    @inlinable
    public init(
        mrzString: String,
        validEnforcement shouldCheckValidity: Bool = true,
        showAlert shouldShowAlert: Bool = false
    ) throws {
        guard Self.checkCharacterIsAcceptable(for: mrzString) else {
            throw PersonalInformationError.invalidCharacter
        }
        
        let separaterIndex = mrzString.index(
            mrzString.startIndex,
            offsetBy: 37
        )
        
        if mrzString[separaterIndex].isNewline {
            guard mrzString.count == 37 * 2 + 1 else {
                throw PersonalInformationError
                    .invalidTotalLength(expected: 37 * 2 + 1)
            }
            
            let mrzCodeLines = mrzString.split(maxSplits: 1, whereSeparator: \.isNewline)
            
            guard mrzCodeLines.count == 2 else {
                throw PersonalInformationError.invalidComposition
            }
            
            for (index, content) in mrzCodeLines.enumerated() {
                guard content.count == 37 else {
                    throw PersonalInformationError.invalidLength(line: index + 1)
                }
            }
            
            try self.init(
                line1: String(mrzCodeLines[0]),
                line2: String(mrzCodeLines[1]),
                validEnforcement: shouldCheckValidity,
                showAlert: shouldShowAlert
            )
        } else {
            guard mrzString.count == 37 * 2 else {
                throw PersonalInformationError
                    .invalidTotalLength(expected: 37 * 2)
            }
            try self.init(
                line1: String(mrzString.prefix(37)),
                line2: String(mrzString.suffix(37)),
                validEnforcement: shouldCheckValidity,
                showAlert: shouldShowAlert
            )
        }
    }
    
    /// Parse personal information from separated MRZ codes.
    /// - Parameters:
    ///   - line1: MRZ code line 1.
    ///   - line2: MRZ code line 2.
    ///   - shouldCheckValidity: Should parser check MRZ's validity, default `true`.
    ///   - shouldShowAlert: Should parser report warning, default `false`.
    @inlinable
    public init(
        line1: String, line2: String,
        validEnforcement shouldCheckValidity: Bool = true,
        showAlert shouldShowAlert: Bool = false
    ) throws {
        guard line1.count == 37, line2.count == 37 else {
            throw PersonalInformationError.invalidMRZCode
        }
        
        // Parse Line 1
        let parts = line1.split(
            separator: "<",
            maxSplits: 1,
            omittingEmptySubsequences: false
        )
        guard parts.count >= 2 else {
            throw PersonalInformationError.nameNotFound
        }

        let departmentID = String(parts[0])
        
        let names = parts[1].split(separator: "<<")
        guard names.count >= 2 else {
            throw PersonalInformationError.nameSeparateError
        }
        
        let familyName = names[0].replacingOccurrences(of: "<", with: " ")
            .trimmingCharacters(in: .whitespaces).capitalized
        let givenName = names[1].replacingOccurrences(of: "<", with: " ")
            .trimmingCharacters(in: .whitespaces).capitalized

        var pointer = line2.startIndex

        // cardId (8) + check digit (1)
        let cardIdEnd = line2.index(pointer, offsetBy: 8)
        let cardIDRaw = String(line2[pointer..<cardIdEnd])
        guard Self.isContainsOnly(
            cardIDRaw,
            in: .uppercaseLetters
                .union(.decimalDigits)
                .union(.init(charactersIn: "<"))
        ) else {
            throw PersonalInformationError.unexpectedLetters(
                line: 2,
                column: Self.indexDistance(of: pointer, in: line2),
                accepted: "/[0-9A-Z<]/"
            )
        }
        let cardID = cardIDRaw.replacingOccurrences(of: "<", with: "")
        if shouldCheckValidity { // valid check
            let cardCheckDigit = line2[cardIdEnd]
            let calculatedCardCheck = PIDCalculateVerificationCode(
                of: line2,
                range: pointer..<cardIdEnd
            )
            
            guard cardCheckDigit == calculatedCardCheck.first else {
                throw PersonalInformationError.veriCodeUnvalidated(
                    .cardID, found: cardCheckDigit
                )
            }
        }
        
        pointer = line2.index(cardIdEnd, offsetBy: 1) // move pointer

        // nationality (3)
        let nationalityEnd = line2.index(pointer, offsetBy: 3)
        let nationality = String(line2[pointer..<nationalityEnd])
        guard Self.isContainsOnly(
            nationality,
            in: .uppercaseLetters
        ) else {
            throw PersonalInformationError.unexpectedLetters(
                line: 2,
                column: Self.indexDistance(of: pointer, in: line2),
                accepted: "A-Z"
            )
        }
        pointer = nationalityEnd // move pointer

        // dateOfBirth (6) + check digit (1)
        let dobEnd = line2.index(pointer, offsetBy: 6)
        let dobString = String(line2[pointer..<dobEnd])
        guard Self.isContainsOnly(
            dobString,
            in: .decimalDigits
        ) else {
            throw PersonalInformationError.unexpectedLetters(
                line: 2,
                column: Self.indexDistance(of: pointer, in: line2),
                accepted: "0-9"
            )
        }
        let dateOfBirth = PIDParseDateFromMRZString(dobString)
        if shouldCheckValidity { // valid check
            let dobCheckDigit = line2[dobEnd]
            let calculatedDOBCheck = PIDCalculateVerificationCode(
                of: line2,
                range: pointer..<dobEnd
            )
            guard dobCheckDigit == calculatedDOBCheck.first else {
                throw PersonalInformationError.veriCodeUnvalidated(
                    .dateOfBirth, found: dobCheckDigit
                )
            }
        }
        pointer = line2.index(dobEnd, offsetBy: 1)

        // gender
        let genderChar = line2[pointer]
        if !genderChar.unicodeScalars.allSatisfy({
            CharacterSet(charactersIn: "MFPO").contains($0)
        }), shouldShowAlert {
            print(
                """
                Gender field in line 2 contains bad character.
                Expected one of MFPO, found \(genderChar). Parsed as O.
                """
            )
        }
        let gender: Gender = switch genderChar {
        case "M": .male
        case "F": .female
        case "P": .preferNotToSay
        default: .other
        }
        pointer = line2.index(after: pointer)

        // validDate (6)
        let validDateEnd = line2.index(pointer, offsetBy: 6)
        let validDateString = String(line2[pointer..<validDateEnd])
        guard Self.isContainsOnly(
            validDateString,
            in: .decimalDigits
        ) else {
            throw PersonalInformationError.unexpectedLetters(
                line: 2,
                column: Self.indexDistance(of: pointer, in: line2),
                accepted: "0-9"
            )
        }
        let validDate = PIDParseDateFromMRZString(
            validDateString,
            pivotYear: 70
        )
        pointer = validDateEnd // move pointer

        // personalId (8) + check digit (1)
        let personalIdEnd = line2.index(pointer, offsetBy: 8)
        let personalIDRaw = String(line2[pointer..<personalIdEnd])
        guard Self.isContainsOnly(
            personalIDRaw,
            in: .uppercaseLetters
                .union(.decimalDigits)
                .union(.init(charactersIn: "<"))
        ) else {
            throw PersonalInformationError.unexpectedLetters(
                line: 2,
                column: Self.indexDistance(of: pointer, in: line2),
                accepted: "/[0-9A-Z<]/"
            )
        }
        let personalID = personalIDRaw.replacingOccurrences(of: "<", with: "")
        if shouldCheckValidity {
            let personalIdCheckDigit = line2[personalIdEnd]
            let calculatedPersonalCheck = PIDCalculateVerificationCode(
                of: line2,
                range: pointer..<personalIdEnd
            )
            guard personalIdCheckDigit == calculatedPersonalCheck.first else {
                throw PersonalInformationError.veriCodeUnvalidated(
                    .personalID, found: personalIdCheckDigit
                )
            }
        }
        
        // final verification code (2)
        if shouldCheckValidity {
            pointer = line2.index(personalIdEnd, offsetBy: 1) // move pointer
            
            let finalCheckEnd = line2.index(pointer, offsetBy: 2)
            let finalCheck = String(line2[pointer..<finalCheckEnd])
            let calculatedFinalCheck = PIDCalculateFinalVerificationCode(
                of: String(line2.prefix(finalCheckEnd.utf16Offset(in: line2) - 2))
            )
            guard finalCheck == calculatedFinalCheck else {
                throw PersonalInformationError.veriCodeUnvalidated(
                    .final, found: finalCheck
                )
            }
        }

        self.init(
            givenName: givenName,
            familyName: familyName,
            nationality: nationality,
            gender: gender,
            dateOfBirth: dateOfBirth,
            personalID: personalID,
            cardID: cardID,
            departmentID: departmentID,
            validDate: validDate
        )
    }
}

extension PersonalInformation {
    @inlinable
    package static func checkCharacterIsAcceptable(for string: String) -> Bool {
        let acceptCharacterSet = CharacterSet.uppercaseLetters
            .union(.decimalDigits)
            .union(.init(charactersIn: "<"))
            .union(.newlines)
        
        return isContainsOnly(string, in: acceptCharacterSet)
    }
    
    @inlinable
    package static func isContainsOnly(_ string: String, in set: CharacterSet) -> Bool {
        return string.rangeOfCharacter(from: set.inverted) == nil
    }
    
    @inlinable
    package static func indexDistance(of index: String.Index, in string: String) -> Int {
        return string.distance(from: string.startIndex, to: index)
    }
}
