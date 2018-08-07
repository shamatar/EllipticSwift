//
//  U256+Aux.swift
//  EllipticSwift
//
//  Created by Alexander Vlasov on 13.07.2018.
//  Copyright © 2018 Alexander Vlasov. All rights reserved.
//

import Foundation
import Accelerate

extension U256 {
    public static var one: U256 {
        return vU256(v: (vUInt32(1), vUInt32(0)))
    }
    
    public static var zero: U256 {
        return vU256(v: (vZERO, vZERO))
    }
}
