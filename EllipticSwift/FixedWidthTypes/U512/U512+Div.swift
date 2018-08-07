//
//  U512+Div.swift
//  EllipticSwift
//
//  Created by Alexander Vlasov on 01.08.2018.
//  Copyright © 2018 Alexander Vlasov. All rights reserved.
//

import Foundation
import Accelerate

extension U512 {
    public func div(_ a: U512) -> (U512, U512) {
        var result = U512()
        var remainder = U512()
        var aCopy = a
        var selfCopy = self
        vU512Divide(&selfCopy, &aCopy, &result, &remainder)
        return (result, remainder)
    }
}
