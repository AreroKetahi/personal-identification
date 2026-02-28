//
//  LookUpTable.swift
//  personal-identification
//
//  Created by Arkivili Collindort on 24/12/2025
//

// Index -> Character
@inlinable
package func PIDIndexToCharacter(_ index: Int) -> Character? {
    switch index {
    case 0...9:
        return Character(String(index))
        
    case 10...35:
        return Character(UnicodeScalar(index - 10 + 65)!) // A = 65
        
    default:
        return nil
    }
}

// Character -> Index
@inlinable
package func PIDCharacterToIndex(_ character: Character) -> Int? {
    guard let scalar = character.unicodeScalars.first else {
        return nil
    }
    
    switch scalar.value {
    case 48...57: // '0'...'9'
        return Int(scalar.value - 48)
        
    case 65...90: // 'A'...'Z'
        return Int(scalar.value - 65 + 10)
        
    default:
        return nil
    }
}

@inlinable
package func PIDFinalVerifyCodeToIndex(_ str: String) -> Int {
    precondition(str.count == 2)
    
    let chars = Array(str)
    let firstValue = PIDCharacterToIndex(chars[0]) ?? 0
    let secondValue = PIDCharacterToIndex(chars[1]) ?? 0
    
    return firstValue *  36 /* PIDCharacterToIndexLoopUpTable.count */ + secondValue
}

@inlinable
package func PIDIndexToFinalVerifyCode(_ index: Int) -> String {
    let base = 36 // PIDCharacterToIndexLoopUpTable.count
    
    let firstValue = index / base
    let secondValue = index % base
    
    let firstChar = PIDIndexToCharacter(firstValue)!
    let secondChar = PIDIndexToCharacter(secondValue)!
    
    return String([firstChar, secondChar])
}
