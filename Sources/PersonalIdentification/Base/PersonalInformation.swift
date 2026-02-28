//
//  PersonalInformation.swift
//  personal-identification
//
//  Created by Arkivili Collindort on 24/12/2025
//

import Foundation

/// Personal Information Definition
public struct PersonalInformation: Codable {
    /// Bearer's given name.
    public var givenName: String
    
    /// Bearer's family name.
    public var familyName: String

    /// Bearer's nationality, in ISO-3166: Alpha 3 format.
    public var nationality: String  // 3
    
    /// Bearer's gender
    public var gender: Gender  // 1
    
    /// Bearer's date of birth.
    public var dateOfBirth: Date  // 6

    /// Bearer's unique personal id, no more than 8-digits.
    public var personalID: String  // <8
    
    /// Unique card id of current identification, no more than 8-digits.
    public var cardID: String  // <8

    /// Bearer's department ID, in 3-digits.
    public var departmentID: String  // 3

    /// Current identification's expiry date.
    public var validDate: Date  // 6

    @inlinable
    public init(
        givenName: String,
        familyName: String,
        nationality: String,
        gender: Gender,
        dateOfBirth: Date,
        personalID: String,
        cardID: String,
        departmentID: String,
        validDate: Date
    ) {
        self.givenName = givenName
        self.familyName = familyName
        self.nationality = nationality
        self.gender = gender
        self.dateOfBirth = dateOfBirth
        self.personalID = personalID
        self.cardID = cardID
        self.departmentID = departmentID
        self.validDate = validDate
    }
}
