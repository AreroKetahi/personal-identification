//
//  ColorSign.swift
//  personal-identification
//
//  Created by Arkivili Collindort on 21/01/2026
//

import Crypto
import Foundation

extension PersonalInformation {
    public func colorSignature() -> [CodeColor] {
        let mrz = self.createMRZLine1Code() + self.createMRZLine2Code()
        
        let digest = SHA384.hash(data: mrz.data(using: .utf8)!)
        let digestData = digest.withUnsafeBytes { Data($0) }
        
        var out = [UInt8](repeating: 0, count: 24)
        for i in 0..<24 {
            out[i] = digestData[i] ^ digestData[i + 24]
        }
        
        return out.map {
            CodeColor(rawValue: $0 % 8)!
        }
    }
    
    public func colorSignatureWithCorrectionCode() -> (signature: [CodeColor], correction: [CodeColor]) {
        let signatureColors: [CodeColor] = self.colorSignature()
        
        let segments: [(range: Range<Int>, parity: Int)] = [
            (0..<5, 3),
            (5..<10, 3),
            (10..<15, 3),
            (15..<20, 3),
            (20..<24, 4)
        ]
        
        var correction: [CodeColor] = []
        
        for seg in segments {
            let dataSymbols = signatureColors[seg.range].map { $0.rawValue }
            let paritySymbols = rsEncodeGF8(data: dataSymbols, parity: seg.parity)
            correction.append(contentsOf: paritySymbols.map {
                CodeColor(rawValue: $0)!
            })
        }
        
        return (signature: signatureColors, correction: correction)
    }
}
