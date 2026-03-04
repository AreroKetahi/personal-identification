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

    @inline(__always)
    static func div(_ a: UInt8, _ b: UInt8) -> UInt8 {
        if a == 0 { return 0 }
        if b == 0 { return 0 }
        let la = Int(log[Int(a)])
        let lb = Int(log[Int(b)])
        let index = (la - lb + 7) % 7
        return exp[index]
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

package func rsSyndromeGF8(data: [UInt8], parity: [UInt8]) -> [UInt8] {
    let codeword = data + parity
    var syndromes = [UInt8](repeating: 0, count: parity.count)

    for j in 0..<parity.count {
        var sum: UInt8 = 0
        for (index, symbol) in codeword.enumerated() {
            if symbol == 0 { continue }
            let power = (j * index) % 7
            let coefficient = GF8.exp[power]
            sum = GF8.add(sum, GF8.mul(symbol, coefficient))
        }
        syndromes[j] = sum
    }

    return syndromes
}

package func rsCorrectErrorsGF8(
    data: [UInt8],
    parity: [UInt8],
    maxErrors: Int
) -> (data: [UInt8], parity: [UInt8], correctedIndices: [Int])? {
    let optionalData = data.map { Optional($0) }
    let optionalParity = parity.map { Optional($0) }
    guard let result = rsCorrectErrorsWithErasuresGF8(
        data: optionalData,
        parity: optionalParity,
        maxErrors: maxErrors
    ) else {
        return nil
    }
    return (
        data: result.data,
        parity: result.parity,
        correctedIndices: result.correctedIndices
    )
}

package func rsCorrectErrorsWithErasuresGF8(
    data: [UInt8?],
    parity: [UInt8?],
    maxErrors: Int
) -> (data: [UInt8], parity: [UInt8], correctedIndices: [Int], erasureIndices: [Int])? {
    let dataCount = data.count
    let parityCount = parity.count

    var erasureIndices: [Int] = []
    for (index, value) in data.enumerated() where value == nil {
        erasureIndices.append(index)
    }
    for (index, value) in parity.enumerated() where value == nil {
        erasureIndices.append(dataCount + index)
    }

    if erasureIndices.count > parityCount {
        return nil
    }

    let maxErrorsAllowed = min(maxErrors, (parityCount - erasureIndices.count) / 2)

    let erasureSet = Set(erasureIndices)

    var bestData: [UInt8] = []
    var bestParity: [UInt8] = []
    var bestCorrectedIndices: [Int] = []
    var bestErrors = Int.max

    var candidate = [UInt8](repeating: 0, count: dataCount)

    func evaluateCandidate() {
        let parityCandidate = rsEncodeGF8(data: candidate, parity: parityCount)
        var errors = 0
        var correctedIndices: [Int] = []

        for index in 0..<dataCount {
            if let observed = data[index] {
                if observed != candidate[index] {
                    errors += 1
                    correctedIndices.append(index)
                }
            }
        }

        for index in 0..<parityCount {
            if let observed = parity[index] {
                if observed != parityCandidate[index] {
                    errors += 1
                    correctedIndices.append(dataCount + index)
                }
            }
        }

        if errors <= maxErrorsAllowed, errors < bestErrors {
            bestErrors = errors
            bestData = candidate
            bestParity = parityCandidate
            bestCorrectedIndices = correctedIndices
        }
    }

    func backtrack(_ index: Int, currentErrors: Int) {
        if currentErrors > maxErrorsAllowed {
            return
        }

        if index == dataCount {
            evaluateCandidate()
            return
        }

        for value in UInt8(0)...UInt8(7) {
            let newErrors: Int
            if let observed = data[index] {
                newErrors = currentErrors + (observed == value ? 0 : 1)
            } else {
                newErrors = currentErrors
            }
            candidate[index] = value
            backtrack(index + 1, currentErrors: newErrors)
            if bestErrors == 0 {
                return
            }
        }
    }

    backtrack(0, currentErrors: 0)

    if bestErrors == Int.max {
        return nil
    }

    let correctedIndices = bestCorrectedIndices.filter { !erasureSet.contains($0) }

    return (
        data: bestData,
        parity: bestParity,
        correctedIndices: correctedIndices,
        erasureIndices: erasureIndices
    )
}
