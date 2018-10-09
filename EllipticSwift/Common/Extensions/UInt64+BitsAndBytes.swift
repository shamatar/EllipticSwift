//
//  UInt64+BitsAndBytes.swift
//  EllipticSwift
//
//  Created by Alex Vlasov on 25.09.2018.
//  Copyright © 2018 Alex Vlasov. All rights reserved.
//

import Foundation

extension UInt64: BitsAndBytes {
    public var bytes: Data {
        return self.bigEndianBytes
    }
    
    public func bit(_ i: Int) -> Bool {
        return self & (UInt64(1) << i) != 0
    }
    
    public var fullBitWidth: UInt32 {
        return 64
    }
    
    public var isZero: Bool {
        return self == 0
    }
    
    public static var zero: UInt64 {
        return UInt64(0)
    }
    
    public var bigEndianBytes: Data {
        var selfCopy = self.bigEndian
        var data = Data(repeating: 0, count: 8)
        withUnsafePointer(to: &selfCopy) { (p) -> Void in
            p.withMemoryRebound(to: UInt8.self, capacity: 8, { (ptr) -> Void in
                for i in 0 ..< 8 {
                    data[i] = ptr.advanced(by: i).pointee
                }
            })
        }
        return data
    }
    
    public var littleEndianBytes: Data {
        var selfCopy = self.littleEndian
        var data = Data(repeating: 0, count: 8)
        withUnsafePointer(to: &selfCopy) { (p) -> Void in
            p.withMemoryRebound(to: UInt8.self, capacity: 8, { (ptr) -> Void in
                for i in 0 ..< 8 {
                    data[i] = ptr.advanced(by: i).pointee
                }
            })
        }
        return data
    }
}
