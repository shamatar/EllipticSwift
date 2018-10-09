//
//  U128.swift
//  EllipticSwift
//
//  Created by Alexander Vlasov on 13.07.2018.
//  Copyright © 2018 Alexander Vlasov. All rights reserved.
//

import Foundation
import Accelerate
import simd

let U128bitLength = 128
let U128byteLength = 16
let U128words = 4
let U128vectors = 1
let U128MAX = vU128(Data(repeating: 255, count: U128byteLength))!
let U128MIN = vU128(Data(repeating: 0, count: U128byteLength))!

extension vU128 {
    public static var bitWidth: Int = U128bitLength
    public static var max: vU128 = U128MAX
    public static var min: vU128 = U128MIN
    
    public init(_ value: UInt32) {
        self = vU128(v: vUInt32(x: value, y: 0, z: 0, w: 0))
    }
    
    public init?(_ bytes: Data) { // assumes BE bytes
        if bytes.count <= U128byteLength {
            let padding = Data(repeating: 0, count: U128byteLength - bytes.count)
            var fullData = (padding + bytes).bytes
            var vectors = [vUInt32](repeating: vZERO, count: U128vectors)
            for i in 0 ..< U128vectors {
                var words = [UInt32](repeating: 0, count: 4)
                for j in 0 ..< 4 {
                    let idx = i*16 + j*4
                    var word: UInt32 = UInt32(fullData[idx + 3]) // encode as BE
                    word += UInt32(fullData[idx + 2]) << 8
                    word += UInt32(fullData[idx + 1]) << 16
                    word += UInt32(fullData[idx + 0]) << 24
                    words[j] = word
                }
                let vec = vUInt32(words[3], words[2], words[1], words[0])
                vectors[i] = vec
            }
            let res = vU128.init(v: vectors[0])
            self = res
        } else {
            return nil
        }
    }
    
    public func add(_ a: vU128) -> vU128 {
        return vU128(v: vU128Add(self.v, a.v))
    }
    
    public func mul(_ a: vU128) -> vU256 {
        var result = vU256()
        var aCopy = a
        var selfCopy = self
        vU128FullMultiply(&selfCopy, &aCopy, &result)
        return result
    }
    
    public func halfMul(_ a: vU128) -> vU128 {
        return vU128(v: vU128HalfMultiply(self.v, a.v))
    }
    
    public func memoryStructure() -> [UInt32] {
        let vecs = self.v
        var arr = [UInt32]()
        arr.append(vecs.x)
        arr.append(vecs.y)
        arr.append(vecs.z)
        arr.append(vecs.w)
        return arr
    }
    
    public var clippedValue: UInt64 {
        return self.v.clippedValue
    }
    
    public var bytes: Data {
        return self.v.bigEndianBytes
    }
    
    public var isZero: Bool {
        return self.v.isZero
    }
}
