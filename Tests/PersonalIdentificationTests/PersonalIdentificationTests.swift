import Testing
import Foundation
@testable import PersonalIdentification

let gender: [Gender] = [.male, .female, .other]
let firstName = ["Foo", "Bar", "Baz"]
let lastName = ["Quux", "Corge", "Grault"]

let name: [(String, String)] = firstName.flatMap { first in
    lastName.map { last in
        (first, last)
    }
}

@Test("CrewID creation, MRZ deparsing and parsing round-trip", arguments: gender, name)
func crewIDCreationAndMRZParsing(gender: Gender, name: (String, String)) async throws {
    // Construct a CrewID
    let originalCrew = try PersonalInformation(
        givenName: name.0,
        familyName: name.1,
        nationality: "ZZZ",
        gender: gender,
        dateOfBirth: Date("31/12/1999", strategy: .dateTime.year().month().day()),
        personalID: "PERSID",
        cardID: "MYCARD",
        departmentID: "DPT",
        validDate: Date("01/01/2050", strategy: .dateTime.year().month().day())
    )
    
    // Generate MRZ code
    let mrz = originalCrew.createMRZCode()
    let lines = mrz.split(separator: "\n").map(String.init)
    #expect(lines.count >= 2, "MRZ should produce at least two lines")
    
    // Parse CrewID back from MRZ
    let parsedCrew = try PersonalInformation(line1: lines[0], line2: lines[1])
    
    // Check round-trip integrity (relaxing some formatting differences)
    #expect(parsedCrew.givenName == originalCrew.givenName, "Given names should match")
    #expect(parsedCrew.familyName == originalCrew.familyName, "Family names should match")
    #expect(parsedCrew.personalID == originalCrew.personalID, "Personal IDs should match")
    #expect(parsedCrew.cardID == originalCrew.cardID, "Card IDs should match")
    #expect(parsedCrew.nationality == originalCrew.nationality, "Nationalities should match")
    #expect(Calendar.current.isDate(parsedCrew.dateOfBirth, inSameDayAs: originalCrew.dateOfBirth), "Birthdates should match")
    #expect(Calendar.current.isDate(parsedCrew.validDate, inSameDayAs: originalCrew.validDate), "Valid dates should match")
    #expect(parsedCrew.gender == originalCrew.gender, "Genders should match")
    print("MRZ Line 1: \(lines[0])\nMRZ Line 2: \(lines[1])")
}
