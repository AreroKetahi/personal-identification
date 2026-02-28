//
//  Verify.swift
//  personal-identification
//
//  Created by Arkivili Collindort on 25/12/2025
//

import Foundation
import ArgumentParser
import PersonalIdentification

struct Verify: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "verify",
        abstract: "Verify tools.",
        subcommands: [VerifyMRZ.self, VerifySignature.self,]
    )
}
