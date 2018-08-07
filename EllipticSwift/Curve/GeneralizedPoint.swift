//
//  GeneralizedPoint.swift
//  EllipticSwift
//
//  Created by Alexander Vlasov on 03.08.2018.
//  Copyright © 2018 Alexander Vlasov. All rights reserved.
//

import Foundation
import BigInt

public struct GeneralizedAffinePoint<T>: AffinePointProtocol where T: CurveProtocol {
    public typealias ProjectiveType = GeneralizedProjectivePoint<T>
    public typealias Curve = T
    public typealias FE = T.FieldElement
    public typealias UnderlyingRawType = T.Field.UnderlyingRawType
    
    public var description: String {
        return self.coordinates.description
    }
    
    public var curve: Curve
    public var isInfinity: Bool = true
    public var rawX: FE
    public var rawY: FE
    public var X: UnderlyingRawType {
        return self.rawX.nativeValue
    }
    public var Y: UnderlyingRawType {
        return self.rawY.nativeValue
    }
    
    public var coordinates: AffineCoordinates {
        if !self.isInfinity {
            return AffineCoordinates(BigUInt(self.X.bytes), BigUInt(self.Y.bytes))
        } else {
            var p = AffineCoordinates(0, 0)
            p.setInfinity()
            return p
        }
    }
    
    public init(_ rawX: FE, _ rawY: FE, _ curve: Curve) {
        self.rawX = rawX
        self.rawY = rawY
        self.curve = curve
        self.isInfinity = false
    }
    
    public func toProjective() -> ProjectiveType {
        if self.isInfinity {
            return ProjectiveType.infinityPoint(self.curve)
        }
        let field = self.curve.field
        let one = FE.identityElement(field)
        let p = ProjectiveType(self.rawX, self.rawY, one, curve)
        return p
    }
    
    public func isEqualTo(_ other: GeneralizedAffinePoint<T>) -> Bool {
        return self.rawX == other.rawX && self.rawY == other.rawY
    }
    
    public static func == (lhs: GeneralizedAffinePoint<T>, rhs: GeneralizedAffinePoint<T>) -> Bool {
        return lhs.isEqualTo(rhs)
    }
    
//    public static func *<U> (lhs: U, rhs: GeneralizedAffinePoint<T>) -> ProjectiveType where U: FiniteFieldCompatible {
//        return rhs.curve.mul(lhs, rhs)
//    }
//    
//    public static func + (lhs: T.AffineType, rhs: T.AffineType) -> ProjectiveType {
//        return lhs.curve.mixedAdd(lhs.toProjective(), rhs)
//    }
}

public struct GeneralizedProjectivePoint<T>: ProjectivePointProtocol where T: CurveProtocol {
    // also refered as Jacobian Point
    public typealias AffineType = GeneralizedAffinePoint<T>
    public typealias Curve = T
    public typealias FE = T.FieldElement
    public typealias UnderlyingRawType = T.Field.UnderlyingRawType
    
    public var curve: Curve
    
    public var isInfinity: Bool {
        return self.rawZ.isZero
    }
    public var rawX: FE
    public var rawY: FE
    public var rawZ: FE
    
    public static func infinityPoint<U>(_ curve: U) -> GeneralizedProjectivePoint<U> where U: CurveProtocol {
        let field = curve.field
        let zero = U.FieldElement.zeroElement(field)
        let one = U.FieldElement.identityElement(field)
        return GeneralizedProjectivePoint<U>(zero, one, zero, curve)
    }
    
    public func isEqualTo(_ other: GeneralizedProjectivePoint<T>) -> Bool {
        return self.toAffine().isEqualTo(other.toAffine())
    }
    
    public init(_ rawX: FE, _ rawY: FE, _ rawZ: FE, _ curve: Curve) {
        self.rawX = rawX
        self.rawY = rawY
        self.rawZ = rawZ
        self.curve = curve
    }
    
    public func toAffine() -> AffineType {
        if self.isInfinity {
            let field = curve.field
            let zero = FE.zeroElement(field)
            var p = AffineType(zero, zero, self.curve)
            p.isInfinity = true
            return p
        }
        let zInv = self.rawZ.inv()
        let zInv2 = zInv * zInv
        let zInv3 = zInv2 * zInv
        let affineX = self.rawX * zInv2
        let affineY = self.rawY * zInv3
        return AffineType(affineX, affineY, self.curve)
    }
    
    public static func == (lhs: GeneralizedProjectivePoint<T>, rhs: GeneralizedProjectivePoint<T>) -> Bool {
        return lhs.isEqualTo(rhs)
    }
    
//    public static func + (lhs: GeneralizedProjectivePoint<T>, rhs: GeneralizedProjectivePoint<T>) -> GeneralizedProjectivePoint<T> {
//        return lhs.curve.add(lhs, rhs)
//    }
//
//    public static func - (lhs: GeneralizedProjectivePoint<T>, rhs: GeneralizedProjectivePoint<T>) -> GeneralizedProjectivePoint<T> {
//        return lhs.curve.sub(lhs, rhs)
//    }
//
//    public static func * (lhs: FiniteFieldCompatible, rhs: GeneralizedProjectivePoint<T>) -> GeneralizedProjectivePoint<T> {
//        if rhs.isInfinity {
//            return rhs
//        }
//        return rhs.curve.mul(lhs, rhs.toAffine())
//    }
//
//    public static func + (lhs: GeneralizedProjectivePoint<T>, rhs: GeneralizedAffinePoint<T>) -> GeneralizedProjectivePoint<T> {
//        return lhs.curve.mixedAdd(lhs, rhs)
//    }
}
