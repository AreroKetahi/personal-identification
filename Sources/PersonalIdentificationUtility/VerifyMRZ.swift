//
//  VerifyMRZ.swift
//  personal-identification
//
//  Created by Arkivili Collindort on 28/12/2025
//

import ArgumentParser
import PersonalIdentification

struct VerifyMRZ: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "mrz",
        abstract: "Verify MRZ data."
    )

    @Argument(help: "MRZ Line 1") var line1: String
    @Argument(help: "MRZ Line 2") var line2: String?

    @Flag(
        name: [.long, .short],
        help: "Show alert"
    ) var alert: Bool = false

    @Flag(
        name: [.long, .short],
        help: "Return error if MRZ verification fails."
    ) var strictMode: Bool = false

    @Flag(
        name: [.long],
        help: "Ignore input cases, and port it to upper case."
    ) var caseInsensitive: Bool = false

    func run() throws {
        let line1 = caseInsensitive ? line1.uppercased() : line1
        let line2 = caseInsensitive ? line2?.uppercased() : line2

        let info = try PIUExtractInformationFrom(
            line1: line1,
            line2: line2,
            strictMode: strictMode,
            showAlert: alert,
            caseInsensitive: caseInsensitive
        )

        print(
            """
            Family Name: \(info.familyName)
            Given Name:  \(info.givenName)
            Gender       \(info.gender.rawValue)
            Nationality: \(info.nationality)
            DOB:         \(info.dateOfBirth.formatted(.dateTime.year().month().day()))

            Depart. ID:  \(info.departmentID)
            Personal ID: \(info.personalID)
            Card ID:     \(info.cardID)
            Valid Until: \(info.validDate.formatted(.dateTime.year().month().day())) (\(info.validDate > .now ? "Valid" : "Expired"))

            Verification: \(actualLine2 == info.createMRZLine2Code() ? "Verified": "Failed")
            """
        )
    }

    var actualLine2: String {
        let line1 = caseInsensitive ? line1.uppercased() : line1
        let line2 = caseInsensitive ? line2?.uppercased() : line2

        if let line2 { return line2 } else { return String(line1.suffix(37)) }
    }
}
