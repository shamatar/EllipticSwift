//
//  U512+Aux.swift
//  EllipticSwift
//
//  Created by Alexander Vlasov on 30.07.2018.
//  Copyright © 2018 Alexander Vlasov. All rights reserved.
//

import Foundation
import Accelerate

extension U512 {
    public static var one: U512 {
        return vU512(v: (vUInt32(1), vUInt32(0), vUInt32(0), vUInt32(0)))
    }
    
    public static var zero: U512 {
        return vU512(v: (vZERO, vZERO, vZERO, vZERO))
    }
}
