//
//  TupleU256+Aux.swift
//  EllipticSwift
//
//  Created by Alex Vlasov on 11/10/2018.
//  Copyright © 2018 Alex Vlasov. All rights reserved.
//

import Foundation

extension TupleU256 {
    public var wordCount: Int {
        if self[3] != 0 {
            return 4
        } else if self[2] != 0 {
            return 3
        } else if self[1] != 0 {
            return 2
        } else if self[0] != 0 {
            return 1
        }
        return 0
    }
}

extension TupleU256: UInt64Initializable {
    
}

extension TupleU256: FastZeroInitializable {
    public static var zero: TupleU256 {
        let res = TupleU256()
        return res
    }
}

extension TupleU256: EvenOrOdd {
    public var isEven: Bool {
        return self[0] & UInt64(1) == 0
    }
}

extension TupleU256: CustomDebugStringConvertible {

    public var debugDescription: String {
        return self.words.debugDescription
    }

    public var words: [UInt64] {
        var res = [UInt64](repeating: 0, count: U256WordWidth)
        for i in 0 ..< U256WordWidth {
            res[i] = self[i]
        }
        return res
    }
}
