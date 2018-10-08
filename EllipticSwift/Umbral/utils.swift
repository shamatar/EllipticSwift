//
//  utils.swift
//  ReEncryptHealth
//
//  Created by Anton Grigorev on 06.10.2018.
//  Copyright © 2018 Anton Grigorev. All rights reserved.
//

import Foundation

//TODO: - hashes
func kdf(ecpoint: Point, keyLength: Int) -> [UInt8] {
    let data = ecpoint.toBytes(isCompressed: true) //TODO: - Needs to be implemented?
    
    return HKDF(algorithm: hashes.BLAKE2b(64),
                length: keyLength,
                salt: nil,
                info: nil,
                backend: defaultBackend()
            ).derive(data)
}

