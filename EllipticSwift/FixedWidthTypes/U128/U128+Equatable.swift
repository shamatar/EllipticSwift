//
//  U128+Equitable.swift
//  EllipticSwift
//
//  Created by Alexander Vlasov on 14.07.2018.
//  Copyright © 2018 Alexander Vlasov. All rights reserved.
//

import Foundation
import Accelerate

extension vU128: Equatable {
    public static func == (lhs: vU128, rhs: vU128) -> Bool {
        return lhs.v == rhs.v
    }
}
