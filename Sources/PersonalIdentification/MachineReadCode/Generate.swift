//
//  Generate.swift
//  personal-identification
//
//  Created by Arkivili Collindort on 24/12/2025
//

import Foundation

extension PersonalInformation {
    /// Creat MRZ code.
    /// - Returns: MRZ code, separate with \n.
    @inlinable
    public func createMRZCode() -> String {
        let firstLine = createMRZLine1Code()
        let secondLine = createMRZLine2Code()
        
        return "\(firstLine)\n\(secondLine)"
    }
}

// MARK: - Line 1

extension PersonalInformation {
    /// Create MRZ code line 1.
    /// - Returns: MRZ code line 1.
    @inlinable
    public func createMRZLine1Code() -> String {
        let asciiDepartmentID = Self.asciiNormalizedDepartmentID(departmentID)
        let asciiFamilyName = Self.asciiNormalizedName(familyName)
        let asciiGivenName = Self.asciiNormalizedName(givenName)
        let firstLine = "\(asciiDepartmentID)<\(asciiFamilyName)<<\(asciiGivenName.replacingOccurrences(of: " ", with: "<"))"
        return firstLine
            .padding(toLength: 37, withPad: "<", startingAt: 0)
            .uppercased()
    }
}

extension PersonalInformation {
    @inlinable
    static func asciiNormalizedName(_ name: String) -> String {
        let normalized = name.folding(
            options: [.diacriticInsensitive, .widthInsensitive],
            locale: Locale(identifier: "en_US_POSIX")
        )
        let allowed = CharacterSet.alphanumerics.union(.whitespaces)
        return String(
            normalized.unicodeScalars.filter {
                $0.isASCII && allowed.contains($0)
            }
        )
    }

    @inlinable
    static func asciiNormalizedDepartmentID(_ departmentID: String) -> String {
        let normalized = departmentID.folding(
            options: [.diacriticInsensitive, .widthInsensitive],
            locale: Locale(identifier: "en_US_POSIX")
        )
        let allowed = CharacterSet.alphanumerics
        return String(
            normalized.unicodeScalars.filter {
                $0.isASCII && allowed.contains($0)
            }
        )
    }
}

// MARK: - Line 2
extension PersonalInformation {
    /// Create MRZ code line 2.
    /// - Returns: MRZ code line 2.
    @inlinable
    public func createMRZLine2Code() -> String {
        let cardID = Self.asciiNormalizedIdentifier(cardID, maxLength: 8)
        let personalID = Self.asciiNormalizedIdentifier(personalID, maxLength: 8)
        let cardIDPadded = cardID.padding(toLength: 8, withPad: "<", startingAt: 0)
        let personalIDPadded = personalID.padding(toLength: 8, withPad: "<", startingAt: 0)

        var secondLine = "\(cardIDPadded)"  // 8
        let startIndex = secondLine.startIndex
        let endIndexOfCardId = secondLine.index(startIndex, offsetBy: 8)
        
        secondLine.append(
            PIDCalculateVerificationCode(
                of: secondLine,
                range: startIndex..<endIndexOfCardId
            )
        )  // 1
        secondLine.append(nationality)  // 3
        secondLine.append(PIDCreateDate(of: dateOfBirth))  // 6
        
        let startIndexOfDOB = secondLine.index(endIndexOfCardId, offsetBy: 4)
        let endIndexOfDOB = secondLine.index(startIndexOfDOB, offsetBy: 6)
        secondLine.append(
            PIDCalculateVerificationCode(
                of: secondLine,
                range: startIndexOfDOB..<endIndexOfDOB
            )
        )  // 1
        
        let gender = switch gender {
        case .male: "M"
        case .female: "F"
        case .other: "O"
        case .preferNotToSay: "P"
        case .unknown(let value): value
        }
        secondLine.append(gender)  // 1
        
        secondLine.append(PIDCreateDate(of: validDate))  // 6
        secondLine.append(personalIDPadded)  // 8
        
        let startIndexOfPersonalId = secondLine.index(
            endIndexOfDOB,
            offsetBy: 8
        )
        let endIndexOfPersonalId = secondLine.index(
            startIndexOfPersonalId,
            offsetBy: 8
        )
        secondLine.append(
            PIDCalculateVerificationCode(
                of: secondLine,
                range: startIndexOfPersonalId..<endIndexOfPersonalId
            )
        )  // 1
        
        secondLine.append(PIDCalculateFinalVerificationCode(of: secondLine))  // 2
        
        return secondLine.uppercased()
    }
}

extension PersonalInformation {
    @inlinable
    static func asciiNormalizedIdentifier(
        _ identifier: String,
        maxLength: Int
    ) -> String {
        let normalized = identifier.folding(
            options: [.diacriticInsensitive, .widthInsensitive],
            locale: Locale(identifier: "en_US_POSIX")
        )
        let allowed = CharacterSet.alphanumerics
        let filtered = String(
            normalized.unicodeScalars.filter {
                $0.isASCII && allowed.contains($0)
            }
        )
        if filtered.count <= maxLength {
            return filtered
        }
        return String(filtered.prefix(maxLength))
    }
}
