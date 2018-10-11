//
//  TupleU256+Add.swift
//  EllipticSwift
//
//  Created by Alex Vlasov on 11/10/2018.
//  Copyright © 2018 Alex Vlasov. All rights reserved.
//

import Foundation

extension TupleU256 {
    
    public func addMod(_ a: TupleU256) -> TupleU256 {
        var opResult = TupleU256()
        var OF = false
        var aCopy = a
        for i in 0 ..< U256WordWidth {
            var (result, newOF) = self[i].addingReportingOverflow(aCopy[i])
            if OF {
                result = result &+ 1
            }
            opResult[i] = result
            OF = newOF
        }
        return opResult
    }
    
    public mutating func inplaceAddMod(_ a: TupleU256) {
        var OF = false
        var aCopy = a
        for i in 0 ..< U256WordWidth {
            var (result, newOF) = self[i].addingReportingOverflow(aCopy[i])
            if OF {
                result = result &+ 1
            }
            self[i] = result
            OF = newOF
        }
    }
}
