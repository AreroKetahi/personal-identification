//
//  Date+Parsable.swift
//  personal-identification
//
//  Created by Arkivili Collindort on 25/12/2025
//

import Foundation
import ArgumentParser

extension Date: @retroactive ExpressibleByArgument {
    public init?(argument: String) {
        if let date = try? Date.parseDate(argument) {
            self = date
        } else {
            return nil
        }
    }
    
    static func parseDate(_ input: String) throws -> Date {
        let patterns = [
            "yyyyMMdd",
            "yyMMdd",
            "dd/MM/yyyy",
            "d/M/yyyy",
            "yyyy/M/d",
            "yyyy-MM-dd"
        ]
        let formatters: [DateFormatter] = patterns.map { formatter($0) }
        
        for formatter in formatters {
            if let date = formatter.date(from: input) {
                return date
            }
        }
        
        throw ValidationError("Invalid date format.")
    }
    
    static func formatter(_ format: String) -> DateFormatter {
        let f = DateFormatter()
        f.dateFormat = format
        f.locale = Locale(identifier: "en_US_POSIX")
        f.timeZone = TimeZone(secondsFromGMT: 0)
        return f
    }
}
