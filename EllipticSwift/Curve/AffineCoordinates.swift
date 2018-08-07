//
//  AffineCoordinates.swift
//  EllipticSwift
//
//  Created by Alexander Vlasov on 10.07.2018.
//  Copyright © 2018 Alexander Vlasov. All rights reserved.
//

import Foundation
import BigInt

public struct AffineCoordinates: CustomStringConvertible {
    public var description: String {
        if self.isInfinity {
            return "Point of O"
        } else {
            return "Point " + "(0x" + String(self.X, radix: 16) + ", 0x" + String(self.Y, radix: 16) + ")"
        }
    }
    
    public var isInfinity: Bool = false
    public var X: BigUInt
    public var Y: BigUInt
    public init(_ x: BigUInt, _ y: BigUInt) {
        self.X = x
        self.Y = y
    }
    internal mutating func setInfinity() {
        self.isInfinity = true
    }
}
