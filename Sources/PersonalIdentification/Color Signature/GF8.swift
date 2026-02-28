//
//  GF8.swift
//  personal-identification
//
//  Created by Arkivili Collindort on 21/01/2026
//

package enum GF8 {
    // primitive polynomial: x^3 + x + 1 = 0b1011
    private static let primitive: UInt8 = 0b1011
    
    static let exp: [UInt8] = {
        var table = [UInt8](repeating: 0, count: 14)
        var x: UInt8 = 1
        for i in 0..<7 {
            table[i] = x
            x <<= 1
            if (x & 0b1000) != 0 { x ^= primitive }
            x &= 0b0111
        }
        for i in 7..<14 { table[i] = table[i - 7] }
        return table
    }()
    
    static let log: [UInt8] = {
        var table = [UInt8](repeating: 0, count: 8)
        for i in 0..<7 {
            table[Int(exp[i])] = UInt8(i)
        }
        return table
    }()
    
    @inline(__always)
    static func add(_ a: UInt8, _ b: UInt8) -> UInt8 { a ^ b }
    
    @inline(__always)
    static func mul(_ a: UInt8, _ b: UInt8) -> UInt8 {
        if a == 0 || b == 0 { return 0 }
        let la = Int(log[Int(a)])
        let lb = Int(log[Int(b)])
        return exp[la + lb]
    }
}

package func rsGeneratorPolynomial(parity: Int) -> [UInt8] {
    var g: [UInt8] = [1]
    for i in 0..<parity {
        let a = GF8.exp[i]
        var next = [UInt8](repeating: 0, count: g.count + 1)
        for j in 0..<g.count {
            next[j]     ^= GF8.mul(g[j], a)
            next[j + 1] ^= g[j]
        }
        g = next
    }
    return g
}

package func rsEncodeGF8(data: [UInt8], parity: Int) -> [UInt8] {
    let generator = rsGeneratorPolynomial(parity: parity)
    var buffer = [UInt8](repeating: 0, count: parity)
    
    for symbol in data {
        let feedback = symbol ^ buffer[0]
        for i in 0..<(parity - 1) {
            buffer[i] = buffer[i + 1] ^ GF8.mul(feedback, generator[i])
        }
        buffer[parity - 1] = GF8.mul(feedback, generator[parity - 1])
    }
    return buffer
}
