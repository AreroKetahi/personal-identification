//
//  VerifyCodeCalculation.swift
//  personal-identification
//
//  Created by Arkivili Collindort on 24/12/2025
//

import RealModule

@inlinable
package func PIDCalculateVerificationCode(
    of string: String,
    range: Range<String.Index>
) -> String {
    let string = string.uppercased()
    var sum = 0
    for (index, character) in string[range].enumerated() {
        let characterIndexNumber = PIDCharacterToIndex(character) ?? 0
        let weight = PIDCalculateWeight(index: index)
        let product = characterIndexNumber * weight
        sum += product
    }
    let remainder = sum % 36
    return String(PIDIndexToCharacter(remainder)!)
}

@inlinable
package func PIDCalculateFinalVerificationCode(of string: String) -> String {
    let string = string.uppercased()
    var sum = 0
    for (index, character) in string.enumerated() {
        let weight = PIDCalculateWeight(index: index)
        let product = (PIDCharacterToIndex(character) ?? 0) * weight
        sum += product
    }
    let remainder = sum % (36 * 36)
    return PIDIndexToFinalVerifyCode(remainder)
}

@inlinable
package func PIDCalculateWeight(index: Int) -> Int {
    let cal1 = Double.pow(2, 37 - (index + 1))
    let remainder = cal1.truncatingRemainder(dividingBy: 37)
    return Int(remainder)
}
