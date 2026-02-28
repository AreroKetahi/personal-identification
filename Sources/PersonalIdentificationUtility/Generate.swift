//
//  Generate.swift
//  personal-identification
//
//  Created by Arkivili Collindort on 25/12/2025
//

import ArgumentParser
import PersonalIdentification
import Foundation

struct Generate: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "generate",
        abstract: "Generate tools.",
        subcommands: [GenerateMRZ.self, GenerateKeypair.self,]
    )
}
