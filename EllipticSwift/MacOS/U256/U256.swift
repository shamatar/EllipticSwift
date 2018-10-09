//
//  U128.swift
//  EllipticSwift
//
//  Created by Alexander Vlasov on 12.07.2018.
//  Copyright © 2018 Alexander Vlasov. All rights reserved.
//

import Foundation
import Accelerate

let U256words = 8
let U256vectors = 2
let vU256MAX = vU256(Data(repeating: 255, count: U256ByteLength))!
let vU256MIN = vU256(Data(repeating: 0, count: U256ByteLength))!

extension vU256: FiniteFieldCompatible {
}

extension vU256: BytesInitializable, BytesRepresentable {
    
    public init?(_ bytes: Data) {
        if bytes.count <= U256ByteLength {
            let padding = Data(repeating: 0, count: U256ByteLength - bytes.count)
            var fullData = (padding + bytes).bytes
            let top = vU128(Data(fullData[0 ..< U128byteLength]))!
            let bottom = vU128(Data(fullData[U128byteLength ..< U256ByteLength]))!
            self = vU256(v: (bottom.v, top.v))
        } else {
            return nil
        }
    }
    
    public var bytes: Data {
        return self.v.1.bigEndianBytes + self.v.0.bigEndianBytes
    }
    
    public func memoryStructure() -> [UInt32] {
        let vecs = self.v
        var arr = [UInt32]()
        arr.append(vecs.0.x)
        arr.append(vecs.0.y)
        arr.append(vecs.0.z)
        arr.append(vecs.0.w)
        arr.append(vecs.1.x)
        arr.append(vecs.1.y)
        arr.append(vecs.1.z)
        arr.append(vecs.1.w)
        return arr
    }
    
    public func split() -> (vU128, vU128) {
        return (vU128(v: self.v.1), vU128(v: self.v.0))
    }
    
    public var isZero: Bool {
        return self.v.0.isZero && self.v.1.isZero
    }
}

extension vU256: UInt64Initializable {
    public init(_ value: UInt64) {
        let top = value >> 32
        let bot = value & 0xffffffff
        let u256 = vU256(v: (vUInt32(x: UInt32(bot), y: UInt32(top), z: 0, w: 0), vZERO))
        self = u256
    }
}


