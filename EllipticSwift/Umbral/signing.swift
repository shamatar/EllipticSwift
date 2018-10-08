//
//  signing.swift
//  ReEncryptHealth
//
//  Created by Anton Grigorev on 06.10.2018.
//  Copyright © 2018 Anton Grigorev. All rights reserved.
//

import Foundation

class Signer {
    
    var _cryptographyPriateKey: UmbralPrivateKey?
    var _curve: Curve?
    
    init(privateKey: UmbralPrivateKey) {
        self._cryptographyPriateKey = privateKey.toCryptographyPrivkey()
        self._curve = privateKey.params?.curve
    }
    
}

