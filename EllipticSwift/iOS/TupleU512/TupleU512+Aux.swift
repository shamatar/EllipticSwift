//
//  TupleU512+Aux.swift
//  EllipticSwift
//
//  Created by Alex Vlasov on 11/10/2018.
//  Copyright © 2018 Alex Vlasov. All rights reserved.
//

import Foundation

extension TupleU512: CustomDebugStringConvertible {
    
    public var debugDescription: String {
        return self.words.debugDescription
    }
    
    public var words: [UInt64] {
        var res = [UInt64](repeating: 0, count: U512WordWidth)
        for i in 0 ..< U512WordWidth {
            res[i] = self[i]
        }
        return res
    }
}
