# ``PersonalIdentification``

@Metadata {
    @DisplayName("Personal Identification")
}

A library that use to generate and verify personal identification MRZ,
as well as create and verify digital signature.

## Overview

By using this library, you can easily create a person's information by using ``PersonalInformation``.

```swift
let info = PersonalInformation(
    givenName: "Foo",
    familyName: "Bar",
    nationality: "ZZZ",
    gender: .male,
    dateOfBirth: /* date of birth */,
    personalID: "AB012345",
    cardID: "CARD1",
    departmentID: "DTP",
    validDate: /* valid until */
)
```

Then, use ``PersonalInformation/createMRZCode()`` to generate a Machine Readable Code.

## Topics

### Standard

- <doc:Personal-Identification-Guideline>

### Base Structures

- ``PersonalInformation``
- ``Gender``

### MRZ Generate

- ``PersonalInformation/createMRZCode()``
- ``PersonalInformation/createMRZLine1Code()``
- ``PersonalInformation/createMRZLine2Code()``

### MRZ Parse

- ``PersonalInformation/init(mrzString:validEnforcement:showAlert:)``
- ``PersonalInformation/init(line1:line2:validEnforcement:showAlert:)``

### Sign and Verify

- ``PersonalInformation/sign(with:)``
- ``PersonalInformation/sign(_:with:)``
- ``PersonalInformation/sign(line1:line2:with:)``

- ``PersonalInformation/verifySignature(_:with:)``
- ``PersonalInformation/verifySignature(_:for:with:)``
- ``PersonalInformation/verifySignature(_:line1:line2:with:)``

### Errors

- ``PersonalInformationError``
