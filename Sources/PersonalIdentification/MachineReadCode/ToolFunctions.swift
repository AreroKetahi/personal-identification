//
//  ToolFunctions.swift
//  personal-identification
//
//  Created by Arkivili Collindort on 24/12/2025
//

import Foundation

@inlinable
package func PIDCreateDate(of date: Date) -> String {
    let calendar = Calendar(identifier: .iso8601)
    let coms = calendar.dateComponents([.year, .month, .day], from: date)
    return "\(String(coms.year!).suffix(2))\(String(format: "%02d", coms.month!))\(String(format: "%02d", coms.day!))"
}

@inlinable
package func PIDParseDateFromMRZString(_ string: String, pivotYear: Int = 50) -> Date {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyMMdd"
    formatter.timeZone = TimeZone(secondsFromGMT: 0)
    guard let shortDate = formatter.date(from: string) else { return Date() }
    
    let yearStr = String(string.prefix(2))
    guard let year = Int(yearStr) else { return shortDate }
    
    let calendar = Calendar(identifier: .gregorian)
    let currentYearTwoDigits = calendar.component(.year, from: Date()) % 100
    
    var components = calendar.dateComponents([.year, .month, .day], from: shortDate)
    
    if year <= currentYearTwoDigits + pivotYear && year >= currentYearTwoDigits - (100 - pivotYear) {
        // 2000年代
        components.year = 2000 + year
    } else {
        // 1900年代
        components.year = 1900 + year
    }
    return calendar.date(from: components) ?? shortDate
}
