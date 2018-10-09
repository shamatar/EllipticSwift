//
//  U512.swift
//  EllipticSwift
//
//  Created by Alexander Vlasov on 13.07.2018.
//  Copyright © 2018 Alexander Vlasov. All rights reserved.
//

import Foundation
import Accelerate

extension vU512 {
    public init?(_ bytes: Data) {
        if bytes.count <= U512ByteLength {
            let padding = Data(repeating: 0, count: U512ByteLength - bytes.count)
            var fullData = (padding + bytes).bytes
            let v3 = vU128(Data(fullData[0 ..< U128byteLength]))!
            let v2 = vU128(Data(fullData[U128byteLength ..< U128byteLength*2]))!
            let v1 = vU128(Data(fullData[U128byteLength*2 ..< U128byteLength*3]))!
            let v0 = vU128(Data(fullData[U128byteLength*3 ..< U512ByteLength]))!
            self = vU512(v: (v0.v, v1.v, v2.v, v3.v))
        } else {
            return nil
        }
    }
    
    public var bytes: Data {
        return self.v.3.bigEndianBytes + self.v.2.bigEndianBytes + self.v.1.bigEndianBytes + self.v.0.bigEndianBytes
    }
        
    public func split() -> (vU256, vU256) {
        let vs = self.v
        let top = vU256(v: (vs.2, vs.3))
        let bottom = vU256(v: (vs.0, vs.1))
        return (top, bottom)
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
        arr.append(vecs.2.x)
        arr.append(vecs.2.y)
        arr.append(vecs.2.z)
        arr.append(vecs.2.w)
        arr.append(vecs.3.x)
        arr.append(vecs.3.y)
        arr.append(vecs.3.z)
        arr.append(vecs.3.w)
        return arr
    }
    
    public var isZero: Bool {
        return self.v.0.isZero && self.v.1.isZero && self.v.2.isZero && self.v.3.isZero
    }
}
