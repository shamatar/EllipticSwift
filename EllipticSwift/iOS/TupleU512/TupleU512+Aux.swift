//
//  TupleU512+Aux.swift
//  EllipticSwift
//
//  Created by Alex Vlasov on 11/10/2018.
//  Copyright © 2018 Alex Vlasov. All rights reserved.
//

import Foundation

extension TupleU512 {
    public var wordCount: Int {
        for i in (0 ..< U512WordWidth).reversed() {
            if self[i] != 0 {
                return i + 1
            }
        }
        return 0
    }
}

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

extension TupleU512 {
    public func split() -> (TupleU256, TupleU256) {
        let bottom = TupleU256((self.storage.0, self.storage.1, self.storage.2, self.storage.3))
        let top = TupleU256((self.storage.4, self.storage.5, self.storage.6, self.storage.7))
        return (top, bottom)
    }
}
