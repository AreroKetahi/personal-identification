//
//  PersonalInformationError.swift
//  personal-identification
//
//  Created by Arkivili Collindort on 24/12/2025
//

public enum PersonalInformationError: Error {
    case invalidMRZCode
    
    case invalidComposition
    case invalidCharacter
    case invalidTotalLength(expected: Int)
    case invalidLength(line: Int)
    case unexpectedLetters(line: Int, column: Int, accepted: String)
    
    // parse line 1
    case nameNotFound
    case nameSeparateError
    
    // parse line 2
    case veriCodeUnvalidated(_ type: _VerificationCodeType, found: String)
    
    
    @inlinable
    static func veriCodeUnvalidated(_ type: _VerificationCodeType, found: Character) -> Self {
        return .veriCodeUnvalidated(type, found: String(found))
    }
}

extension PersonalInformationError: CustomStringConvertible {
    public var description: String {
        switch self {
        case .invalidMRZCode: 
            "Invalid MRZ Code."
        case .invalidComposition:
            #"""
            Invalid MRZ composition. 
            Expected 2 lines with newline as separator.
            """#
        case .invalidCharacter:
            #"""
            MRZ contains unexpected characters. 
            Only 0-9, A-Z, and "<" are accepted.
            """#
        case .invalidTotalLength(let length):
            #"""
            Invalid MRZ length. 
            Expected \#(length) characters.
            """#
        case .invalidLength(let line):
            #"""
            Invalid MRZ line length. Expeceted 37 characters. 
            Founded mismatch at line \#(line).
            """#
            
        case .nameNotFound:
            #"""
            Person name not found at line 1.
            Expected name after 3-digits Department ID, separater with "<".
            """#
        case .nameSeparateError:
            #"""
            Could not separate family name and given name. 
            Expected family name and given name separated with "<<", and all space in given name should be replaced with "<".
            """#
        case .unexpectedLetters(let line, let column, let accpetRange):
            #"""
            Unexpected letter found at line \#(line), column \#(column).
            Accept \#(accpetRange) only.
            """#
        case .veriCodeUnvalidated(let type, let foundedCode):
            #"""
            \#(type.description) validation failed.
            Found invalid verification code: \#(foundedCode).
            """#
        }
    }
}

public enum _VerificationCodeType: Sendable, CustomStringConvertible {
    case cardID, dateOfBirth, personalID, final
    
    public var description: String {
        switch self {
        case .cardID:
            "Card ID"
        case .dateOfBirth:
            "Card of Birth"
        case .personalID:
            "Personal ID"
        case .final:
            "Final Check Code"
        }
    }
}
