//
//  dem.swift
//  ReEncryptHealth
//
//  Created by Anton Grigorev on 06.10.2018.
//  Copyright © 2018 Anton Grigorev. All rights reserved.
//

import Foundation

let DEM_KEYSIZE = 32
let DEM_NONCE_SIZE = 12

class UmbralDEM {
    
    //TODO: - cipher Type?
    var cipher:
    
    init(symmKey: [UInt8]) {
        
        if symmKey.count != DEM_KEYSIZE {
            precondition(false)
        }
        
        //TODO: - chacha?
        self.cipher = ChaCha20Poly1305(symmKey)
    }
    
    //TODO: -
    func encrypt(data: [UInt8], authenticatedData: [UInt8]? = nil) -> [UInt8] {
        let nonce = urandom(DEM_NONCE_SIZE) //TODO: - how?
        let encData = self.cipher.encrypt(nonce, data, authenticatedData) //TODO: -
        return nonce + encData
    }
    
    func decrypt(ciphertext: [UInt8], authenticatedData: [UInt8]? = nil) -> [UInt8] {
        let nonce = ciphertext[0...DEM_NONCE_SIZE]
        let ciphertext = ciphertext[DEM_NONCE_SIZE...(ciphertext.count-1)]
        let cleartext = self.cipher.decrypt(nonce, ciphertext, authenticatedData)
        return cleartext
    }
}

