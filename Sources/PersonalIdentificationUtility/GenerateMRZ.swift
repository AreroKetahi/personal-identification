//
//  GenerateMRZ.swift
//  personal-identification
//
//  Created by Arkivili Collindort on 28/12/2025
//

import ArgumentParser
import PersonalIdentification
import Foundation

struct GenerateMRZ: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "mrz",
        abstract: "Generate personal identification MRZ code."
    )
    
    @Option(name: [.long, .customShort("f")]) var familyName:   String
    @Option(name: [.long, .customShort("g")]) var givenName:    String
    @Option(name: [.long, .customShort("n")]) var nationality:  String
    @Option(name: [.long, .customShort("s")]) var gender:       Gender
    @Option(name: [.long, .customShort("b")]) var dateOfBirth:  Date
    @Option(name: [.long, .customShort("p")]) var personalID:   String
    @Option(name: [.long, .customShort("c")]) var cardID:       String
    @Option(name: [.long, .customShort("d")]) var departmentID: String
    @Option(name: [.long, .customShort("v")]) var validDate:    Date
    
    func run() throws {
        let personalInformation = PersonalInformation(
            givenName:      givenName,
            familyName:     familyName,
            nationality:    nationality,
            gender:         gender,
            dateOfBirth:    dateOfBirth,
            personalID:     personalID,
            cardID:         cardID,
            departmentID:   departmentID,
            validDate:      validDate
        )
        
        print(
            """
            Line 1: \(personalInformation.createMRZLine1Code())
            Line 2: \(personalInformation.createMRZLine2Code())
            """
        )
    }
}
