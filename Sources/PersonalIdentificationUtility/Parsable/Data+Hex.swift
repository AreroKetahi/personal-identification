//
//  Data+Hex.swift
//  personal-identification
//
//  Created by Arkivili Collindort on 28/12/2025
//

import Foundation

extension Data {
    var hexadecimalEncodedString: String {
        return map { String(format: "%02hhx", $0) }.joined()
    }
    
    init?(hexadecimalEncoded hex: String) {
        let len = hex.count
        
        guard len % 2 == 0 else { return nil }
        
        var data = Data(capacity: len / 2)
        var index = hex.startIndex
        
        for _ in 0..<(len / 2) {
            let nextIndex = hex.index(index, offsetBy: 2)
            let byteStr = hex[index..<nextIndex]
            
            guard let byte = UInt8(byteStr, radix: 16) else { return nil }
            
            data.append(byte)
            index = nextIndex
        }
        
        self = data
    }
}
