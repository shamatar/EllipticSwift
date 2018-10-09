//
//  U512+Div.swift
//  EllipticSwift
//
//  Created by Alexander Vlasov on 01.08.2018.
//  Copyright © 2018 Alexander Vlasov. All rights reserved.
//

import Foundation
import Accelerate

extension vU512 {
    public func div(_ a: vU512) -> (vU512, vU512) {
        var result = vU512()
        var remainder = vU512()
        var aCopy = a
        var selfCopy = self
        vU512Divide(&selfCopy, &aCopy, &result, &remainder)
        return (result, remainder)
    }
}
