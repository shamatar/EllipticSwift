//
//  U128.swift
//  EllipticSwift
//
//  Created by Alexander Vlasov on 12.07.2018.
//  Copyright © 2018 Alexander Vlasov. All rights reserved.
//

import Foundation
import Accelerate

public var U256bitLength = 256
public var U256byteLength = 32
public var U256words = 8
public var U256vectors = 2
public var U256MAX = U256(Data(repeating: 255, count: U256byteLength))!
public var U256MIN = U256(Data(repeating: 0, count: U256byteLength))!

extension U256: BytesInitializable, BytesRepresentable {
    
    public init?(_ bytes: Data) {
        if bytes.count <= U256byteLength {
            let padding = Data(repeating: 0, count: U256byteLength - bytes.count)
            var fullData = (padding + bytes).bytes
            let top = U128(Data(fullData[0 ..< U128byteLength]))!
            let bottom = U128(Data(fullData[U128byteLength ..< U256byteLength]))!
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
    
    public func split() -> (U128, U128) {
        return (U128(v: self.v.1), U128(v: self.v.0))
    }
    
    public var isZero: Bool {
        return self.v.0.isZero && self.v.1.isZero
    }
}

extension U256: UInt64Initializable {
    public init(_ value: UInt64) {
        let top = value >> 32
        let bot = value & 0xffffffff
        let u256 = U256(v: (vUInt32(x: UInt32(bot), y: UInt32(top), z: 0, w: 0), vZERO))
        self = u256
    }
}


