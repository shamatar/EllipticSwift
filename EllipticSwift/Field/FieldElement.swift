//
//  File.swift
//  EllipticSwift
//
//  Created by Alex Vlasov on 24.09.2018.
//  Copyright © 2018 Alex Vlasov. All rights reserved.
//

import Foundation
import BigInt

public struct FieldElement<U>: FieldElementProtocol where U: FieldProtocol {
    public typealias Field = U
    public typealias SelfType = FieldElement<U>
    
    public static func fromValue(_ a: BigUInt, field: Field) -> SelfType {
        let reduced = field.fromValue(a)
        return SelfType(reduced, field)
    }
    
    public static func fromValue(_ a: BytesRepresentable, field: Field) -> SelfType {
        let reduced = field.fromValue(a)
        return SelfType(reduced, field)
    }
    
    public static func fromValue(_ a: U.UnderlyingRawType, field: Field) -> SelfType {
        let reduced = field.fromValue(a)
        return SelfType(reduced, field)
    }
    
    public static func fromValue(_ a: UInt64, field: Field) -> SelfType {
        let reduced = field.fromValue(a)
        return SelfType(reduced, field)
    }
    
    public static func fromBytes(_ a: Data, field: Field) -> SelfType {
        let reduced = field.fromBytes(a)
        return SelfType(reduced, field)
    }
    
    public static func toValue(_ a: Field.UnderlyingRawType, field: Field) -> BigUInt {
        let normal: BigUInt = field.toValue(a)
        return normal
    }
    
    public static func toValue(_ a: Field.UnderlyingRawType, field: Field) -> U.UnderlyingRawType {
        let normal: U.UnderlyingRawType = field.toValue(a)
        return normal
    }
    
    public static func identityElement(_ field: Field) -> SelfType {
        let reduced = field.identityElement
        return SelfType(reduced, field)
    }
    
    public static func zeroElement(_ field: Field) -> SelfType {
        let reduced = field.zeroElement
        return SelfType(reduced, field)
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
            return SelfType.toValue(self.rawValue, field: self.field)
        }
    }
    
    public var nativeValue: Field.UnderlyingRawType {
        get {
            return SelfType.toValue(self.rawValue, field: self.field)
        }
    }
    
    public static func == (lhs: SelfType, rhs: SelfType) -> Bool {
        return lhs.rawValue == rhs.rawValue
    }
    public static func + (lhs: SelfType, rhs: SelfType) -> SelfType {
        let raw = lhs.field.add(lhs.rawValue, rhs.rawValue)
        return SelfType(raw, lhs.field)
    }
    public static func - (lhs: SelfType, rhs: SelfType) -> SelfType {
        let raw = lhs.field.sub(lhs.rawValue, rhs.rawValue)
        return SelfType(raw, lhs.field)
    }
    public static func * (lhs: SelfType, rhs: SelfType) -> SelfType {
        let raw = lhs.field.mul(lhs.rawValue, rhs.rawValue)
        return SelfType(raw, lhs.field)
    }
    public static func * (lhs: BytesRepresentable, rhs: SelfType) -> SelfType {
        let newFE = rhs.field.reduce(lhs)
        let raw = rhs.field.mul(newFE, rhs.rawValue)
        return SelfType(raw, rhs.field)
    }
    public static func + (lhs: BytesRepresentable, rhs: SelfType) -> SelfType {
        let newFE = rhs.field.reduce(lhs)
        let raw = rhs.field.add(newFE, rhs.rawValue)
        return SelfType(raw, rhs.field)
    }
    public func pow(_ a: BytesRepresentable) -> SelfType {
        let p = Field.UnderlyingRawType(a.bytes)
        precondition(p != nil)
        let raw = self.field.pow(self.rawValue, p!)
        return SelfType(raw, self.field)
    }
    public func pow(_ a: Field.UnderlyingRawType) -> SelfType {
        let raw = self.field.pow(self.rawValue, a)
        return SelfType(raw, self.field)
    }
    public func negate() -> SelfType {
        let raw =  self.field.neg(self.rawValue)
        return SelfType(raw, self.field)
    }
    
    public func inv() -> SelfType? {
        return nil
    }
    
    public func sqrt() -> SelfType? {
        return nil
    }
}

extension FieldElement where Field: FieldWithDivisionProtocol {
    public func inv() -> SelfType {
        let raw = self.field.inv(self.rawValue)
        return FieldElement(raw, self.field)
    }
}

extension FieldElement where Field: FieldWithSquareRootProtocol {
    public func sqrt() -> SelfType {
        let raw = self.field.sqrt(self.rawValue)
        return FieldElement(raw, self.field)
    }
}

//extension FieldElement: Arithmetics where Field: FieldWithDivisionProtocol {
//    public typealias Field = U
//    public func pow(_ a: SelfType) -> SelfType {
//        let raw = self.field.pow(self.rawValue, a.nativeValue)
//        return SelfType(raw, self.field)
//    }
//    public static func / (lhs: SelfType, rhs: SelfType) -> (SelfType, SelfType) {
//        let inverse = lhs.field.inv(rhs.rawValue)
//        let raw = lhs.field.mul(lhs.rawValue, inverse)
//        return (SelfType(raw, lhs.field), SelfType.zeroElement(lhs.field))
//    }
//    public static func == (lhs: SelfType, rhs: SelfType) -> Bool {
//        return lhs.rawValue == rhs.rawValue
//    }
//    public static func + (lhs: SelfType, rhs: SelfType) -> SelfType {
//        let raw = lhs.field.add(lhs.rawValue, rhs.rawValue)
//        return SelfType(raw, lhs.field)
//    }
//    public static func * (lhs: SelfType, rhs: SelfType) -> SelfType {
//        let raw = lhs.field.mul(lhs.rawValue, rhs.rawValue)
//        return SelfType(raw, lhs.field)
//    }
//    public static func - (lhs: SelfType, rhs: SelfType) -> SelfType {
//        let raw = lhs.field.sub(lhs.rawValue, rhs.rawValue)
//        return SelfType(raw, lhs.field)
//    }
    
//}
