//
//  config.swift
//  ReEncryptHealth
//
//  Created by Anton Grigorev on 06.10.2018.
//  Copyright © 2018 Anton Grigorev. All rights reserved.
//

import Foundation

//TODO: - Curve?
class Config {
    var _curve: Curve? = nil
    var _params: UmbralParameters? = nil
    
    func setCurveByDefault() {
        setCurve(curve: SECP256K1())
    }
    
    func params() -> UmbralParameters {
        guard let params = _params else {
            setCurveByDefault()
            return _params!
        }
        return params
    }
    
    func curve() -> Curve {
        guard let curve = _curve else {
            setCurveByDefault()
            return _curve!
        }
        return curve
    }
    
    func setCurve(curve: Curve? = nil) {
        if curve == nil {
            curve = SECP256K1()
        }
        _curve = curve
        _params = UmbralParameters(curve: curve!)
    }
    
    func setDefaultCurve(curve: Curve? = nil) {
        setCurve(curve: curve)
    }
    
    func defaultCurve() -> Curve {
        return curve()
    }
    
    func defaultParams() -> UmbralParameters {
        return params()
    }

    
}
