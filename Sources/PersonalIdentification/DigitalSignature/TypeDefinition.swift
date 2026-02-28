//
//  TypeDefinition.swift
//  personal-identification
//
//  Created by Arkivili Collindort on 27/12/2025
//

import Crypto

/// Private key type that specified in *Personal Identification Guildline*.
public typealias PINPrivateKey = Curve25519.Signing.PrivateKey

/// Public key type that specified in *Personal Identification Guildline*.
public typealias PINPublicKey = Curve25519.Signing.PublicKey
