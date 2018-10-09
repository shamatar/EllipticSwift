//
//  U256+Equitable.swift
//  EllipticSwift
//
//  Created by Alexander Vlasov on 13.07.2018.
//  Copyright © 2018 Alexander Vlasov. All rights reserved.
//

import Foundation
import Accelerate

extension vU256: Equatable {
    public static func == (lhs: vU256, rhs: vU256) -> Bool {
        return lhs.v.0 == rhs.v.0 &&
            lhs.v.1 == rhs.v.1
    }
}
