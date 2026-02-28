//
//  Data+Base36.swift
//  personal-identification
//
//  Created by Arkivili Collindort on 28/12/2025
//

import Foundation
import Numerics
import BigInt

extension Data {
    var base36EncodedString: String {
        var number = BigUInt(self)
        if number == 0 { return "0" }
        
        let base36Chars = Array("0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ")
        var result = ""
        
        while number > 0 {
            let (quotient, remainder) = number.quotientAndRemainder(dividingBy: 36)
            result = String(base36Chars[Int(remainder)]) + result
            number = quotient
        }
        
        return result
    }
    
    init?(base36Encoded str: String) {
        let base36Chars = Array("0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ")
        var number = BigUInt(0)
        
        for char in str.uppercased() {
            guard let index = base36Chars.firstIndex(of: char) else {
                return nil
            }
            number = number * 36 + BigUInt(index)
        }
        
        self = number.serialize()
    }
}

// MARK: - UInt128

@available(macOS 15.0, *)
extension UInt128 {
    init?(data: Data) {
        guard data.count <= 16 else { return nil }
        var value: UInt128 = 0
        
        for byte in data {
            value <<= 8
            value |= UInt128(byte)
        }
        
        self = value
    }
    var data: Data {
        var value = self
        var bytes = [UInt8](repeating: 0, count: 16)
        
        for i in (0..<16).reversed() {
            bytes[i] = UInt8(value & 0xff)
            value >>= 8
        }
        
        // 可选择裁剪高位 0
        if let firstNonZero = bytes.firstIndex(where: { $0 != 0 }) {
            return Data(bytes[firstNonZero...])
        } else {
            return Data([0])
        }
    }
}
