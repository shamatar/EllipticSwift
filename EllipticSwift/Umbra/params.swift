//
//  params.swift
//  ReEncryptHealth
//
//  Created by Anton Grigorev on 05.10.2018.
//  Copyright © 2018 Anton Grigorev. All rights reserved.
//

import Foundation
import BigInt

//TODO: - Curve?
class UmbralParameters {
    
    var curveKeySizeBytes: UInt?
    var curve: Curve?
    var g: BigInt?
    var u: BigInt?
    
    init(curve: Curve) {
        self.curve = curve
        self.curveKeySizeBytes = self.curve.fieldOrderSizeInBytes
        
        self.g = Point().getGeneratorFromCurve(curve: curve)
        var gBytes = Array(BigUInt(self.g!).serialize())
        var parametersSeed: [UInt8] = Array("matterinc/UmbralParameters/".utf8) + Array("u".utf8)
        self.u = Point().unsafeHashToPoint(data: gBytes, params: self, label: parametersSeed)
    }
}

