//
//  UInt32.swift
//  EllipticSwift
//
//  Created by Alexander Vlasov on 14.07.2018.
//  Copyright © 2018 Alexander Vlasov. All rights reserved.
//

import Foundation

extension UInt32 {
    public var bigEndianBytes: Data {
        var selfCopy = self.bigEndian
        var data = Data(repeating: 0, count: 4)
        withUnsafePointer(to: &selfCopy) { (p) -> Void in
            p.withMemoryRebound(to: UInt8.self, capacity: 4, { (ptr) -> Void in
                for i in 0 ..< 4 {
                    data[i] = ptr.advanced(by: i).pointee
                }
            })
        }
        return data
    }
    
    public var littleEndianBytes: Data {
        var selfCopy = self.littleEndian
        var data = Data(repeating: 0, count: 4)
        withUnsafePointer(to: &selfCopy) { (p) -> Void in
            p.withMemoryRebound(to: UInt8.self, capacity: 4, { (ptr) -> Void in
                for i in 0 ..< 4 {
                    data[i] = ptr.advanced(by: i).pointee
                }
            })
        }
        return data
    }
}
