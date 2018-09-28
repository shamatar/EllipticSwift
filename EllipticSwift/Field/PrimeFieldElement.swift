//
//  PrimeFieldElement.swift
//  EllipticSwift
//
//  Created by Alexander Vlasov on 02.08.2018.
//  Copyright © 2018 Alexander Vlasov. All rights reserved.
//

import Foundation
import BigInt

public struct PrimeFieldElement<U>: PrimeFieldElementProtocol where U: PrimeFieldProtocol {

    public typealias Field = U
    public typealias SelfType = PrimeFieldElement<U>

    public static func fromValue(_ a: BigUInt, field: Field) -> PrimeFieldElement<U> {
        let reduced = field.fromValue(a)
        return PrimeFieldElement<U>(reduced, field)
    }

    public static func fromValue(_ a: BytesRepresentable, field: Field) -> PrimeFieldElement<U> {
        let reduced = field.fromValue(a)
        return PrimeFieldElement<U>(reduced, field)
    }

    public static func fromValue(_ a: U.UnderlyingRawType, field: Field) -> PrimeFieldElement<U> {
        let reduced = field.fromValue(a)
        return PrimeFieldElement<U>(reduced, field)
    }

    public static func fromValue(_ a: UInt64, field: Field) -> PrimeFieldElement<U> {
        let reduced = field.fromValue(a)
        return PrimeFieldElement<U>(reduced, field)
    }

    public static func fromBytes(_ a: Data, field: Field) -> PrimeFieldElement<U> {
        let reduced = field.fromBytes(a)
        return PrimeFieldElement<U>(reduced, field)
    }

    public static func toValue(_ a: Field.UnderlyingRawType, field: Field) -> BigUInt {
        let normal: BigUInt = field.toValue(a)
        return normal
    }

    public static func toValue(_ a: Field.UnderlyingRawType, field: Field) -> U.UnderlyingRawType {
        let normal: U.UnderlyingRawType = field.toValue(a)
        return normal
    }

    public static func identityElement(_ field: Field) -> PrimeFieldElement<U> {
        let reduced = field.identityElement
        return PrimeFieldElement<U>(reduced, field)
    }

    public static func zeroElement(_ field: Field) -> PrimeFieldElement<U> {
        let reduced = field.zeroElement
        return PrimeFieldElement<U>(reduced, field)
    }

    public func isEqualTo(_ other: SelfType) -> Bool {
        return self.rawValue == other.rawValue
    }

    public var rawValue: Field.UnderlyingRawType

    public init(_ rawValue: Field.UnderlyingRawType, _ field: Field) {
        self.rawValue = rawValue
        self.field = field
    }

    public var isZero: Bool {
        return self.rawValue.isZero
    }
    public var field: Field

    public var value: BigUInt {
        get {
            return PrimeFieldElement<U>.toValue(self.rawValue, field: self.field)
//            return self.field.toValue(self.rawValue)
        }
    }

    public var nativeValue: Field.UnderlyingRawType {
        get {
            return PrimeFieldElement<U>.toValue(self.rawValue, field: self.field)
//            return self.field.toValue(self.rawValue)
        }
    }

    public static func == (lhs: SelfType, rhs: SelfType) -> Bool {
        return lhs.rawValue == rhs.rawValue
    }
    public static func + (lhs: SelfType, rhs: SelfType) -> SelfType {
        let raw = lhs.field.add(lhs.rawValue, rhs.rawValue)
        return PrimeFieldElement(raw, lhs.field)
    }
    public static func - (lhs: SelfType, rhs: SelfType) -> SelfType {
        let raw = lhs.field.sub(lhs.rawValue, rhs.rawValue)
        return PrimeFieldElement(raw, lhs.field)
    }
    public static func * (lhs: SelfType, rhs: SelfType) -> SelfType {
        let raw = lhs.field.mul(lhs.rawValue, rhs.rawValue)
        return PrimeFieldElement(raw, lhs.field)
    }
    public static func * (lhs: BytesRepresentable, rhs: SelfType) -> SelfType {
        let newFE = rhs.field.reduce(lhs)
        let raw = rhs.field.mul(newFE, rhs.rawValue)
        return PrimeFieldElement(raw, rhs.field)
    }
    public static func + (lhs: BytesRepresentable, rhs: SelfType) -> SelfType {
        let newFE = rhs.field.reduce(lhs)
        let raw = rhs.field.add(newFE, rhs.rawValue)
        return PrimeFieldElement(raw, rhs.field)
    }
    public func pow(_ a: BytesRepresentable) -> SelfType {
        let p = Field.UnderlyingRawType(a.bytes)
        precondition(p != nil)
        let raw = self.field.pow(self.rawValue, p!)
        return PrimeFieldElement(raw, self.field)
    }
    public func pow(_ a: Field.UnderlyingRawType) -> SelfType {
        let raw = self.field.pow(self.rawValue, a)
        return PrimeFieldElement(raw, self.field)
    }
    public func inv() -> SelfType {
        let raw = self.field.inv(self.rawValue)
        return PrimeFieldElement(raw, self.field)
    }
    public func sqrt() -> SelfType {
        let raw = self.field.sqrt(self.rawValue)
        return PrimeFieldElement(raw, self.field)
    }
    public func negate() -> SelfType {
        let raw =  self.field.neg(self.rawValue)
        return PrimeFieldElement(raw, self.field)
    }
}

//extension PrimeFieldElement: Arithmetics {
//    public func pow(_ a: PrimeFieldElement<U>) -> PrimeFieldElement<U> {
//        let raw = self.field.pow(self.rawValue, a.nativeValue)
//        return PrimeFieldElement(raw, self.field)
//    }
//
//    public static func / (lhs: PrimeFieldElement<U>, rhs: PrimeFieldElement<U>) -> (PrimeFieldElement<U>, PrimeFieldElement<U>) {
//        let inverse = rhs.inv()
//        return (lhs*inverse, PrimeFieldElement.zeroElement(lhs.field))
//    }
//}


