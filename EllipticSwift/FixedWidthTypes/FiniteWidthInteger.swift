//
//  FiniteWidthInteger.swift
//  EllipticSwift
//
//  Created by Alexander Vlasov on 13.07.2018.
//  Copyright © 2018 Alexander Vlasov. All rights reserved.
//

import Foundation

#if os(OSX)
import Accelerate
public typealias U256 = vU256
public typealias U512 = vU512
public typealias U1024 = vU1024
#elseif os(iOS)
public typealias U256 = TinyUInt256
public typealias U512 = NativeU256
public typealias U1024 = TinyUInt1024
#endif


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
