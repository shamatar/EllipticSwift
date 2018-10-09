//
//  FiniteWidthInteger.swift
//  EllipticSwift
//
//  Created by Alexander Vlasov on 13.07.2018.
//  Copyright © 2018 Alexander Vlasov. All rights reserved.
//

import Foundation

public let U256ByteLength = 32
public let U256BitLength = 256
public let U256WordWidth = 4

public let U512WordWidth = 8
public let U512BitLength = 512
public let U512ByteLength = 64

public protocol FiniteFieldCompatible: Comparable, Numeric, ModReducable, BytesInitializable, BitsAndBytes, BitShiftable, EvenOrOdd, UInt64Initializable, FastZeroInitializable {
}

public protocol BitsAndBytes: BytesRepresentable, BitAccessible, FixedWidth, Zeroable {
}

public protocol UInt64Initializable {
    init(_ value: UInt64)
}

public protocol BytesInitializable {
    init? (_ bytes: Data)
}

// big endian bytes
public protocol BytesRepresentable {
    var bytes: Data {get}
}

public protocol Zeroable {
    var isZero: Bool {get}
}

public protocol FastZeroInitializable {
    static var zero: Self {get}
}

public protocol EvenOrOdd {
    var isEven: Bool {get}
}

public protocol BitAccessible {
    func bit(_ i: Int) -> Bool
}

public protocol FixedWidth {
    var bitWidth: Int {get}
    var leadingZeroBitCount: Int {get}
    var fullBitWidth: UInt32 {get}
}

public protocol BitShiftable {
    static func >> (lhs: Self, rhs: UInt32) -> Self
    static func << (lhs: Self, rhs: UInt32) -> Self
}

public protocol ModReducable {
    func modMultiply(_ a: Self, _ modulus: Self) -> Self
    func mod(_ modulus: Self) -> Self
    func modInv(_ modulus: Self) -> Self
    func div(_ a: Self) -> (Self, Self)
    func fullMultiply(_ a: Self) -> (Self, Self)
}

public protocol MontArithmeticsCompatible {
    static func getMontParams(_ a: Self) -> (Self, Self, Self)
    func toMontForm(_ modulus: Self) -> Self
    func montMul(_ b: Self, modulus: Self, montR: Self, montInvR: Self, montK: Self) -> Self
}
