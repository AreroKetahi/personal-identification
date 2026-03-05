# Personal Identification Guideline

The base structure and specification of this library.

## Overview

This article illustrates the MRZ encoding rule and digital signature standard of Personal Identification library.

Personal Identification allows to encoding following information as a 
Machine Readable code.

|Category     |Description                                                           |Format            |
|-------------|----------------------------------------------------------------------|------------------|
|Given Name   |-                                                                     |-                 |
|Family Name  |-                                                                     |-                 |
|Department ID|3-character ID of certain department.                                 |3, alphanumeric   |
|Card ID      |A card/identification's unique issue ID, this ID should not be reused.|<= 8, alphanumeric|
|Nationality  |An `ISO-3166` code of bearer's nationality.                           |3-digits          |
|Gender       |Gender code, see also **Attachment 1**.                               |1-fixed-digit     |
|Date of Birth|Bearer's date of birth.                                               |6-digits, `yyMMdd`|
|Personal ID  |Bearer's personal ID, this ID should fixed for bearer.                |<= 8, alphanumeric|
|Valid Date   |Card/identification's last valid date.                                |6-digits, `yyMMdd`|

### MRZ Encoding Specification

Personal Identificaiton MRZ Code is a two-line, 37 digits each 
**all-uppercased** alphanumeric string, it allow `<` character to use 
as a separator or emply placeholder.

#### Line 1 Encoding Rule

MRZ Line 1 include 3-character alphanumeric **Department ID**, **given name** and **family name**.

**Department ID** and names are separated with "`<`", **given name** 
and **family name** are separated with "`<<`". Rest of the space 
should be pad with `<`.

Additionally, all spaces in given name should be replace with "`<`". 

- Important: Names are standardized for MRZ output as follows:
  - Latin characters with diacritics are normalized to their ASCII base forms (for example, `É` → `E`).
  - Non-Latin scripts are not transliterated; users must provide Latin names if required.
  - After normalization, only ASCII alphanumerics and spaces are kept, then the result is uppercased.

For example, a person named _John C. Appleseed_ in department 
`EXP` should be written as.

    EXP<APPLESEED<<JOHN<C<<<<<<<<<<<<<<<<

#### Line 2 Encoding Rule

MRZ Line 2 contains rests of the informations, in mask:

    CCCCCCCCVNNNDDDDDDVGLLLLLLPPPPPPPPVFF

1.  `C` is **Card ID**;
2.  First `V` is the verification code of card ID;
3.  `N` is **Nationality Code**;
4.  `D` is **Date of Birth**;
5.  Second `V` is the verification code of date of birth;
6.  `G` is **Gender**;
7.  `L` is **Valid Date**;
8.  `P` is **Personal ID**;
9.  Third `V` is the verification code of personal ID;
10. `F` is the final verification code.

**Card ID** and **Personal ID** are alphanumeric and must not exceed 8 characters, the rest of the spaces should be replace as `<`.

**Nationality** is ISO-3166 Alpha 3 code.

**Date of Birth** and **Valid Date** should be written as `yyMMdd`.
In this case, 1st Jan 1970 should be written as `700101`.

**Gender** is 1-digit fixed representation, see also *Attachment 1*.

##### 1-Digit Verification Code Algorithm

1. Calcuate the weighted sum from start index (1) to end index according to the position in whole string: 

        S = Σ(i = I_start → I_end) W_i × N_character

    `N_character` is the number representation of character, for `0-9` is itself, `A`=10, `B`=11, etc,. `W_i` is the weight in certain index.

        W_i = 2 ^ (37 - i) % 37

2. Calculate the remainder:

        S % 36

    And reverse number `0-35` to character.

##### 2-Digits final Verification Code Algorithm

1. For the last 2-digits verification code, it calcuate the sum from start to the 35th character with _Step 1_ of 1-digit verification code algorithm.

2. Calculate the remainder:

        R = S % 1296

3. Calculate two separate character of verification code:

    For the first character, the character number is

        ⌊R / 36⌋

    For the second character, the character number is

        R % 36

    The verification code is the combination of First Character 
    and Second character.

### Digital Signature Specification

The generated MRZ line 2 and given name, family name, deparment ID will be encode to protocal buffer. The definition of protocal butter as follow:

```protobuf
syntax = "proto3";

message PINSignature {
    string family_name = 1;
    string given_name = 2;
    string department = 3;
    string mrz = 9;
}
```

- Important: Signature are using **Ed25519 Signature Algorithm**.

The serialized protocol butter data will be used to generate the signature. The length of signature should be fixed 64 bytes.

### Color Signature Specification

Color Signature is derived from the MRZ content and encoded as 24 symbols with an additional 16-symbol correction code.

#### Color Signature Generation

1. Concatenate MRZ line 1 and line 2.
2. Calculate SHA-384 digest of the UTF-8 data.
3. XOR the first 24 bytes with the last 24 bytes to produce 24 symbols.
4. Each symbol is mapped by `value % 8` to a `CodeColor` in range `0...7`.

#### Correction Code

The 24 symbols are split into 5 segments:

- `0..<5` with parity length 3
- `5..<10` with parity length 3
- `10..<15` with parity length 3
- `15..<20` with parity length 3
- `20..<24` with parity length 4

For each segment, Reed-Solomon parity over GF(8) is generated and concatenated, producing 16 correction symbols.

#### Correction Input Format

For correction APIs, the packed input is 40 symbols:

- First 24 symbols: signature
- Last 16 symbols: correction

Missing symbols are represented by `nil` and are treated as erasures. The correction capacity is:

    erasures + 2 * errors <= parity

Where `parity` is the segment parity length.

#### Color Code Mapping

Each code color value maps to a display color as follows:

|Color    |Value|Hex      |
|---------|-----|---------|
|white    |0    |`#FFFFFF`|
|black    |1    |`#000000`|
|red      |2    |`#FF0000`|
|green    |3    |`#00FF00`|
|blue     |4    |`#0000FF`|
|yellow   |5    |`#FFFF00`|
|magenta  |6    |`#FF00FF`|
|cyan     |7    |`#00FFFF`|

### Attachment 1: Gender Code

|Gender           |Code|
|-----------------|----|
|Male             |`M` |
|Female           |`F` |
|Prefer Not to Say|`P` |
|Other            |`O` |
