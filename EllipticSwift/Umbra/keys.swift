//
//  keys.swift
//  ReEncryptHealth
//
//  Created by Anton Grigorev on 05.10.2018.
//  Copyright © 2018 Anton Grigorev. All rights reserved.
//

import Foundation
import BigInt

class UmbralPrivateKey {
    
    var params: UmbralParameters?
    var bnKey: BigInt?
    var pubkey: UmbralPublicKey?
    
    init(bnKey: BigInt, params: UmbralParameters) {
        self.params = params
        self.bnKey = bnKey
        self.pubkey = UmbralPublicKey(pointKey: self.bnKey! * params.g!, params: params)
    }
    
    public func genKey(params: UmbralParameters? = nil) -> UmbralPrivateKey {
        var _params: UmbralParameters
        if params == nil {
            _params = Config().defaultParams()
        } else {
            _params = params!
        }
        let bnKey = BigInt().genRand(curve: _params.curve) //TODO: - 
        return UmbralPrivateKey(bnKey: bnKey, params: _params)
    }
    
    public func getPubkey() -> UmbralPublicKey? {
        return self.pubkey ?? nil
    }
    
    //TODO: - How?
    func toCryptographyPrivkey() -> EllipticCurvePrivateKey {
        return key
    }
    
}

class UmbralPublicKey {
    
    var params: UmbralParameters?
    var pointKey: BigInt?
    
    init(pointKey: BigInt, params: UmbralParameters) {
        self.params = params
        self.pointKey = pointKey
    }
}

