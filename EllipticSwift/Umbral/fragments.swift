//
//  fragments.swift
//  ReEncryptHealth
//
//  Created by Anton Grigorev on 06.10.2018.
//  Copyright © 2018 Anton Grigorev. All rights reserved.
//

import Foundation

class CapsuleFrag {
    
    var _pointE1: Point?
    var _pointV1: Point?
    var _kfragId: [UInt8]?
    var _pointNoninteractive: Point?
    var _pointXcoord: Point?
    var proof: CorrectnessProof?
    
    init(pointE1: Point,
        pointV1: Point,
        kfragId: [UInt8],
        pointNoninteractive: Point,
        pointXcoord: Point,
        proof: CorrectnessProof? = nil) {
        self._pointE1 = pointE1
        self._pointV1 = pointV1
        self._kfragId = kfragId
        self._pointNoninteractive = pointNoninteractive
        self._pointXcoord = pointXcoord
        self.proof = proof
    }
    
    func verifyCorrectness(capsule: Capsule) -> Bool {
        return accessCfragCorrectness(scapsule)
    }
    
    
}
