//
//  TupleU512+Sub.swift
//  EllipticSwift
//
//  Created by Alex Vlasov on 12/10/2018.
//  Copyright © 2018 Alex Vlasov. All rights reserved.
//

import Foundation

extension TupleU512 {
    
    public func subMod(_ a: TupleU512) -> TupleU512 {
        var opResult = TupleU512()
        var OF = false
        var aCopy = a
        for i in 0 ..< U512WordWidth {
            var (result, newOF) = self[i].subtractingReportingOverflow(aCopy[i])
            if OF {
                result = result &- 1
            }
            opResult[i] = result
            OF = newOF
        }
        return opResult
    }
    
    public mutating func inplaceSubMod(_ a: TupleU512) {
        var OF = false
        var aCopy = a
        for i in 0 ..< U512WordWidth {
            var (result, newOF) = self[i].subtractingReportingOverflow(aCopy[i])
            if OF {
                result = result &- 1
            }
            self[i] = result
            OF = newOF
        }
    }
}
