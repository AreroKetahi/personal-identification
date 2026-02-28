//
//  ProtobufSupport.swift
//  personal-identification
//
//  Created by Arkivili Collindort on 28/12/2025
//

extension PersonalInformation {
    @usableFromInline
    var protobufRepresentation: PINSignature {
        var bearer = PINSignature()
        bearer.givenName = standaredToSignature(self.givenName)
        bearer.familyName = standaredToSignature(self.familyName)
        bearer.department = standaredToSignature(self.departmentID)
        bearer.mrz = self.createMRZLine2Code()
        return bearer
    }
}
