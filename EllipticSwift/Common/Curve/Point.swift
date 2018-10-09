//
//  GeneralizedPoint.swift
//  EllipticSwift
//
//  Created by Alexander Vlasov on 03.08.2018.
//  Copyright © 2018 Alexander Vlasov. All rights reserved.
//

import Foundation
import BigInt

public struct AffinePoint<T>: AffinePointProtocol where T: CurveProtocol {
    public typealias ProjectiveType = ProjectivePoint<T>
    public typealias Curve = T
    public typealias FE = T.FE
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
    
    public func isEqualTo(_ other: AffinePoint<T>) -> Bool {
        return self.rawX == other.rawX && self.rawY == other.rawY
    }
    
//    public func mul(_ scalar: BytesRepresentable) -> ProjectiveType {
//        guard let scalarNative = T.Field.UnderlyingRawType(scalar.bytes) else {
//            return ProjectiveType.infinityPoint(self.curve)
//        }
//        return self.curve.mul(scalarNative, self as! T.AffineType) as! ProjectivePoint<T>
//    }
    
    public static func == (lhs: AffinePoint<T>, rhs: AffinePoint<T>) -> Bool {
        return lhs.isEqualTo(rhs)
    }
    
    public static func * (lhs: BytesRepresentable, rhs: AffinePoint<T>) -> ProjectiveType {
        return rhs.curve.mul(lhs, rhs as! T.AffineType) as! ProjectivePoint<T>
    }

    public static func + (lhs: AffinePoint<T>, rhs: AffinePoint<T>) -> ProjectiveType {
        return lhs.curve.mixedAdd(lhs.toProjective() as! T.ProjectiveType, rhs as! T.AffineType) as! ProjectivePoint<T>
    }
}

public struct ProjectivePoint<T>: ProjectivePointProtocol where T: CurveProtocol {
    // also refered as Jacobian Point
    public typealias AffineType = AffinePoint<T>
    public typealias Curve = T
    public typealias FE = T.FE
    public typealias UnderlyingRawType = T.Field.UnderlyingRawType
    
    public var curve: Curve
    
    public var isInfinity: Bool {
        return self.rawZ.isZero
    }
    public var rawX: FE
    public var rawY: FE
    public var rawZ: FE
    
    public static func infinityPoint<U>(_ curve: U) -> ProjectivePoint<U> where U: CurveProtocol {
        let field = curve.field
        let zero = U.FE.zeroElement(field)
        let one = U.FE.identityElement(field)
        return ProjectivePoint<U>(zero, one, zero, curve)
    }
    
    public func isEqualTo(_ other: ProjectivePoint<T>) -> Bool {
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
    
    public static func == (lhs: ProjectivePoint<T>, rhs: ProjectivePoint<T>) -> Bool {
        return lhs.isEqualTo(rhs)
    }
    
    public static func + (lhs: ProjectivePoint<T>, rhs: ProjectivePoint<T>) -> ProjectivePoint<T> {
        return lhs.curve.add(lhs as! T.ProjectiveType, rhs as! T.ProjectiveType) as! ProjectivePoint<T>
    }

    public static func - (lhs: ProjectivePoint<T>, rhs: ProjectivePoint<T>) -> ProjectivePoint<T> {
        return lhs.curve.sub(lhs as! T.ProjectiveType, rhs as! T.ProjectiveType) as! ProjectivePoint<T>
    }

    public static func * (lhs: BytesRepresentable, rhs: ProjectivePoint<T>) -> ProjectivePoint<T> {
        if rhs.isInfinity {
            return rhs
        }
        return rhs.curve.mul(lhs, rhs.toAffine() as! T.AffineType) as! ProjectivePoint<T>
    }
}
