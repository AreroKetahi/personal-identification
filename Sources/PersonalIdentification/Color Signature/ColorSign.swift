//
//  ColorSign.swift
//  personal-identification
//
//  Created by Arkivili Collindort on 21/01/2026
//

import Crypto
import Foundation

public enum ColorSignatureError: Error, Sendable {
    case invalidLength(expected: Int, got: Int)
    case invalidSymbol(index: Int, value: UInt8)
    case uncorrectable(segment: Int)
}

public struct ColorSignatureCorrectionResult: Sendable {
    public let signature: [CodeColor]
    public let correction: [CodeColor]
    public let correctedSignature: [CodeColor]
    public let correctedCorrection: [CodeColor]
    public let correctedSegments: [Int]
    public let correctedSymbolCount: Int

    public var packed: [CodeColor] {
        correctedSignature + correctedCorrection
    }
}

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

extension PersonalInformation {
    public static func correctColorSignature(
        signature: [CodeColor],
        correction: [CodeColor]
    ) throws -> ColorSignatureCorrectionResult {
        let expectedSignatureLength = 24
        let expectedCorrectionLength = 16
        guard signature.count == expectedSignatureLength else {
            throw ColorSignatureError.invalidLength(
                expected: expectedSignatureLength,
                got: signature.count
            )
        }
        guard correction.count == expectedCorrectionLength else {
            throw ColorSignatureError.invalidLength(
                expected: expectedCorrectionLength,
                got: correction.count
            )
        }

        let segments: [(range: Range<Int>, parity: Int)] = [
            (0..<5, 3),
            (5..<10, 3),
            (10..<15, 3),
            (15..<20, 3),
            (20..<24, 4)
        ]

        var correctedSignature = signature
        var correctedCorrection = correction
        var correctedSegments: [Int] = []
        var correctedSymbolCount = 0

        func mapSymbols(
            _ symbols: [UInt8],
            offset: Int
        ) throws -> [CodeColor] {
            var colors: [CodeColor] = []
            colors.reserveCapacity(symbols.count)
            for (index, value) in symbols.enumerated() {
                guard let color = CodeColor(rawValue: value) else {
                    throw ColorSignatureError.invalidSymbol(
                        index: offset + index,
                        value: value
                    )
                }
                colors.append(color)
            }
            return colors
        }

        var correctionOffset = 0
        for (segmentIndex, segment) in segments.enumerated() {
            let dataSymbols = correctedSignature[segment.range].map { $0.rawValue }
            let parityRange = correctionOffset..<(correctionOffset + segment.parity)
            let paritySymbols = correctedCorrection[parityRange].map { $0.rawValue }

            guard let result = rsCorrectErrorsGF8(
                data: dataSymbols,
                parity: paritySymbols,
                maxErrors: segment.parity / 2
            ) else {
                throw ColorSignatureError.uncorrectable(segment: segmentIndex)
            }

            if !result.correctedIndices.isEmpty {
                correctedSegments.append(segmentIndex)
                correctedSymbolCount += result.correctedIndices.count
            }

            let correctedData = try mapSymbols(
                result.data,
                offset: segment.range.lowerBound
            )
            let correctedParity = try mapSymbols(
                result.parity,
                offset: expectedSignatureLength + correctionOffset
            )
            correctedSignature.replaceSubrange(segment.range, with: correctedData)
            correctedCorrection.replaceSubrange(parityRange, with: correctedParity)

            correctionOffset += segment.parity
        }

        return ColorSignatureCorrectionResult(
            signature: signature,
            correction: correction,
            correctedSignature: correctedSignature,
            correctedCorrection: correctedCorrection,
            correctedSegments: correctedSegments,
            correctedSymbolCount: correctedSymbolCount
        )
    }

    public static func correctColorSignature(
        packed: [CodeColor]
    ) throws -> ColorSignatureCorrectionResult {
        let expectedPackedLength = 40
        guard packed.count == expectedPackedLength else {
            throw ColorSignatureError.invalidLength(
                expected: expectedPackedLength,
                got: packed.count
            )
        }

        let signature = Array(packed.prefix(24))
        let correction = Array(packed.suffix(16))
        return try correctColorSignature(signature: signature, correction: correction)
    }

    public static func correctColorSignature(
        packed: [CodeColor?]
    ) throws -> ColorSignatureCorrectionResult {
        let expectedPackedLength = 40
        guard packed.count == expectedPackedLength else {
            throw ColorSignatureError.invalidLength(
                expected: expectedPackedLength,
                got: packed.count
            )
        }

        let signature = Array(packed.prefix(24))
        let correction = Array(packed.suffix(16))
        return try correctColorSignature(signature: signature, correction: correction)
    }

    public static func correctColorSignature(
        signature: [CodeColor?],
        correction: [CodeColor?]
    ) throws -> ColorSignatureCorrectionResult {
        let expectedSignatureLength = 24
        let expectedCorrectionLength = 16
        guard signature.count == expectedSignatureLength else {
            throw ColorSignatureError.invalidLength(
                expected: expectedSignatureLength,
                got: signature.count
            )
        }
        guard correction.count == expectedCorrectionLength else {
            throw ColorSignatureError.invalidLength(
                expected: expectedCorrectionLength,
                got: correction.count
            )
        }

        let segments: [(range: Range<Int>, parity: Int)] = [
            (0..<5, 3),
            (5..<10, 3),
            (10..<15, 3),
            (15..<20, 3),
            (20..<24, 4)
        ]

        var correctedSignature = signature
        var correctedCorrection = correction
        var correctedSegments: [Int] = []
        var correctedSymbolCount = 0

        func mapSymbols(
            _ symbols: [UInt8],
            offset: Int
        ) throws -> [CodeColor] {
            var colors: [CodeColor] = []
            colors.reserveCapacity(symbols.count)
            for (index, value) in symbols.enumerated() {
                guard let color = CodeColor(rawValue: value) else {
                    throw ColorSignatureError.invalidSymbol(
                        index: offset + index,
                        value: value
                    )
                }
                colors.append(color)
            }
            return colors
        }

        var correctionOffset = 0
        for (segmentIndex, segment) in segments.enumerated() {
            let dataSymbols = correctedSignature[segment.range].map { $0?.rawValue }
            let parityRange = correctionOffset..<(correctionOffset + segment.parity)
            let paritySymbols = correctedCorrection[parityRange].map { $0?.rawValue }

            guard let result = rsCorrectErrorsWithErasuresGF8(
                data: dataSymbols,
                parity: paritySymbols,
                maxErrors: segment.parity / 2
            ) else {
                throw ColorSignatureError.uncorrectable(segment: segmentIndex)
            }

            let correctedData = try mapSymbols(
                result.data,
                offset: segment.range.lowerBound
            )
            let correctedParity = try mapSymbols(
                result.parity,
                offset: expectedSignatureLength + correctionOffset
            )

            correctedSignature.replaceSubrange(
                segment.range,
                with: correctedData.map { Optional($0) }
            )
            correctedCorrection.replaceSubrange(
                parityRange,
                with: correctedParity.map { Optional($0) }
            )

            if !result.correctedIndices.isEmpty || !result.erasureIndices.isEmpty {
                correctedSegments.append(segmentIndex)
                correctedSymbolCount += result.correctedIndices.count + result.erasureIndices.count
            }

            correctionOffset += segment.parity
        }

        func unwrapSymbols(
            _ symbols: [CodeColor?],
            expectedCount: Int,
            offset: Int
        ) throws -> [CodeColor] {
            var output: [CodeColor] = []
            output.reserveCapacity(symbols.count)
            for (index, value) in symbols.enumerated() {
                guard let value else {
                    throw ColorSignatureError.uncorrectable(segment: offset + index)
                }
                output.append(value)
            }
            if output.count != expectedCount {
                throw ColorSignatureError.invalidLength(
                    expected: expectedCount,
                    got: output.count
                )
            }
            return output
        }

        let resolvedSignature = try unwrapSymbols(
            correctedSignature,
            expectedCount: expectedSignatureLength,
            offset: 0
        )
        let resolvedCorrection = try unwrapSymbols(
            correctedCorrection,
            expectedCount: expectedCorrectionLength,
            offset: expectedSignatureLength
        )

        return ColorSignatureCorrectionResult(
            signature: resolvedSignature,
            correction: resolvedCorrection,
            correctedSignature: resolvedSignature,
            correctedCorrection: resolvedCorrection,
            correctedSegments: correctedSegments,
            correctedSymbolCount: correctedSymbolCount
        )
    }
}
