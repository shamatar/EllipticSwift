//
//  Protocols.swift
//  EllipticSwift
//
//  Created by Alexander Vlasov on 02.08.2018.
//  Copyright © 2018 Alexander Vlasov. All rights reserved.
//

import Foundation
import BigInt

public protocol FiniteFieldProtocol {
    associatedtype ElementType
    associatedtype RawType
//    associatedtype ScalarType
    
//    var modulus: RawType {get}
//
//    init(_ p: RawType)
    
    func isEqualTo(_ other: Self) -> Bool
    
    func areEqual(_ a: ElementType, _ b: ElementType) -> Bool
    func isZero(_ a: ElementType) -> Bool
    
    func add(_ a: ElementType, _ b: ElementType) -> ElementType
    func sub(_ a: ElementType, _ b: ElementType) -> ElementType
    func neg(_ a: ElementType) -> ElementType
    func mul(_ a: ElementType, _ b: ElementType) -> ElementType
//    func pow(_ a: ElementType, _ b: ScalarType) -> ElementType
//    func pow(_ a: ElementType, _ b: ElementType) -> ElementType
    func pow(_ a: ElementType, _ b: BitsAndBytes) -> ElementType
    func inv(_ a: ElementType) -> ElementType
    func sqrt(_ a: ElementType) -> ElementType
    
    func fromValue(_ a: RawType) -> ElementType
//    func fromValue(_ a: UInt64) -> ElementType
//    func fromBytes(_ a: Data) -> ElementType
    func toValue(_ a: ElementType) -> RawType
    
    var identityElement: ElementType {get}
    var zeroElement: ElementType {get}
}


public protocol FieldProtocol {
    associatedtype UnderlyingRawType: FiniteFieldCompatible // U256, U512...

    var modulus: BigUInt {get}

    init(_ p: BigUInt)
    init(_ p: BytesRepresentable)
    init(_ p: UnderlyingRawType)

    func isEqualTo(_ other: Self) -> Bool

    func add(_ a: UnderlyingRawType, _ b: UnderlyingRawType) -> UnderlyingRawType
    func sub(_ a: UnderlyingRawType, _ b: UnderlyingRawType) -> UnderlyingRawType
    func neg(_ a: UnderlyingRawType) -> UnderlyingRawType
    func mul(_ a: UnderlyingRawType, _ b: UnderlyingRawType) -> UnderlyingRawType
    func pow(_ a: UnderlyingRawType, _ b: UnderlyingRawType) -> UnderlyingRawType

    func pow(_ a: UnderlyingRawType, _ b: BytesRepresentable) -> UnderlyingRawType

    func reduce(_ a: BytesRepresentable) -> UnderlyingRawType
    func reduce(_ a: UnderlyingRawType) -> UnderlyingRawType
    func fromValue(_ a: BigUInt) -> UnderlyingRawType
    func fromValue(_ a: BytesRepresentable) -> UnderlyingRawType
    func fromValue(_ a: UnderlyingRawType) -> UnderlyingRawType
    func fromValue(_ a: UInt64) -> UnderlyingRawType
    func fromBytes(_ a: Data) -> UnderlyingRawType
    func toValue(_ a: UnderlyingRawType) -> BigUInt
    func toValue(_ a: UnderlyingRawType) -> UnderlyingRawType

    var identityElement: UnderlyingRawType {get}
    var zeroElement: UnderlyingRawType {get}
}

public protocol FieldWithDivisionProtocol {
    associatedtype UnderlyingRawType: FiniteFieldCompatible
    func inv(_ a: UnderlyingRawType) -> UnderlyingRawType
    func div(_ a: UnderlyingRawType, _ b: UnderlyingRawType) -> UnderlyingRawType
}

public protocol FieldWithSquareRootProtocol {
    associatedtype UnderlyingRawType: FiniteFieldCompatible
    func sqrt(_ a: UnderlyingRawType) -> UnderlyingRawType
}

public protocol PrimeFieldProtocol: FieldProtocol, FieldWithSquareRootProtocol, FieldWithDivisionProtocol {}

public protocol FieldElementProtocol: Equatable {
    associatedtype Field: FieldProtocol
    
    var rawValue: Field.UnderlyingRawType {get}

    func isEqualTo(_ other: Self) -> Bool

    var value: BigUInt  {get}
    var nativeValue: Field.UnderlyingRawType {get}
    var isZero: Bool {get}
    var field: Field {get}

    init(_ rawValue: Field.UnderlyingRawType, _ field: Field)

    static func == (lhs: Self, rhs: Self) -> Bool
    static func + (lhs: Self, rhs: Self) -> Self
    static func - (lhs: Self, rhs: Self) -> Self
    static func * (lhs: Self, rhs: Self) -> Self
    static func * (lhs: BytesRepresentable, rhs: Self) -> Self
    static func + (lhs: BytesRepresentable, rhs: Self) -> Self
    func pow(_ a: BytesRepresentable) -> Self
    func negate() -> Self
    
    static func fromValue(_ a: BigUInt, field: Field) -> Self
    static func fromValue(_ a: BytesRepresentable, field: Field) -> Self
    static func fromValue(_ a: Field.UnderlyingRawType, field: Field) -> Self
    static func fromValue(_ a: UInt64, field: Field) -> Self
    static func fromBytes(_ a: Data, field: Field) -> Self
    static func toValue(_ a: Field.UnderlyingRawType, field: Field) -> BigUInt
    static func toValue(_ a: Field.UnderlyingRawType, field: Field) -> Field.UnderlyingRawType
    static func identityElement(_ field: Field) -> Self
    static func zeroElement(_ field: Field) -> Self
}

public protocol InvertibleFieldElementProtocol {
    associatedtype Field: FieldProtocol, FieldWithDivisionProtocol
    func inv() -> Self
}

public protocol SquareRootableFieldElementProtocol {
    associatedtype Field: FieldProtocol, FieldWithSquareRootProtocol
    func sqrt() -> Self
}

public protocol PrimeFieldElementProtocol: FieldElementProtocol, InvertibleFieldElementProtocol, SquareRootableFieldElementProtocol where Field: PrimeFieldProtocol {

}
