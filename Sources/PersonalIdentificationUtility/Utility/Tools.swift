//
//  Tools.swift
//  personal-identification
//
//  Created by Arkivili Collindort on 28/12/2025
//

import PersonalIdentification

@inlinable
func PIUExtractInformationFrom(
    line1: String,
    line2: String?,
    strictMode: Bool = true,
    showAlert: Bool = false,
    caseInsensitive: Bool
) throws -> PersonalInformation {
    let line1 = caseInsensitive ? line1.uppercased() : line1
    let line2 = caseInsensitive ? line2?.uppercased() : line2
    
    if let line2 {
        return try PersonalInformation(
            line1: line1,
            line2: line2,
            validEnforcement: strictMode,
            showAlert: showAlert
        )
    } else {
        return try PersonalInformation(
            mrzString: line1,
            validEnforcement: strictMode,
            showAlert: showAlert
        )
    }
}
