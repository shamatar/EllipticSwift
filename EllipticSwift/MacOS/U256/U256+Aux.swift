//
//  U256+Aux.swift
//  EllipticSwift
//
//  Created by Alexander Vlasov on 13.07.2018.
//  Copyright © 2018 Alexander Vlasov. All rights reserved.
//

import Foundation
import Accelerate
import BigInt

extension vU256 {
    public static var one: vU256 {
        return vU256(v: (vUInt32(1), vUInt32(0)))
    }
    
    public static var zero: vU256 {
        return vU256(v: (vZERO, vZERO))
    }
}

extension vU256: CustomDebugStringConvertible {
    public var debugDescription: String {
        return String(BigUInt(self.bytes))
    }
}
