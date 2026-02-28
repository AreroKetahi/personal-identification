//
//  Entrypoint.swift
//  personal-identification
//
//  Created by Arkivili Collindort on 25/12/2025
//

import ArgumentParser

@main
struct Entrypoint: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "personal-identification-utility",
        version: "1.0.0",
        subcommands: [Generate.self, Verify.self, Sign.self, ColorSign.self,]
    )
}
