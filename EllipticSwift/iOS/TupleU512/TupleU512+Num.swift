//
//  TupleU512+Num.swift
//  EllipticSwift
//
//  Created by Alex Vlasov on 12/10/2018.
//  Copyright © 2018 Alex Vlasov. All rights reserved.
//

import Foundation

extension TupleU512: Comparable {
    public static func < (lhs: TupleU512, rhs: TupleU512) -> Bool {
        for i in (0 ..< U512WordWidth).reversed() {
            if lhs[i] < rhs[i] {
                return true
            } else if lhs[i] > rhs[i] {
                return false
            }
        }
        return false
    }
    
    public static func == (lhs: TupleU512, rhs: TupleU512) -> Bool {
        for i in 0 ..< U512WordWidth {
            if lhs[i] != rhs[i] {
                return false
            }
        }
        return true
    }
}
