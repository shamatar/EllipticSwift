//
//  ProperExtendableWeierstrassCurve.swift
//  EllipticSwift
//
//  Created by Alex Vlasov on 03/10/2018.
//  Copyright © 2018 Alex Vlasov. All rights reserved.
//


import Foundation
import BigInt

public class ExtendableWeierstrassCurve<F>: CurveProtocol3 where F: FiniteFieldProtocol {
    public typealias Field = F
    public typealias FE = FiniteFieldElement<Field>
    public typealias RawType = FE.RawType
    public typealias ScalarType = U256
    public typealias AffineType = ExtendableAffinePoint<ExtendableWeierstrassCurve<F>>
    public typealias ProjectiveType = ExtendableProjectivePoint<ExtendableWeierstrassCurve<F>>
    
    public var field: Field
    public var order: ScalarType
    
    public var A: FE
    public var B: FE
    
    internal var aIsZero: Bool = false
    internal var bIsZero: Bool = false
    internal lazy var ONE: FE = { FE.identityElement(self.field) }()
    internal lazy var TWO: FE = { self.ONE + self.ONE }()
    internal lazy var THREE: FE = { self.TWO + self.ONE }()
    internal lazy var FOUR: FE = { self.TWO + self.TWO }()
    internal lazy var EIGHT: FE = { self.FOUR + self.FOUR }()
    
    
    public init(field: Field, order: ScalarType, A: RawType, B: RawType) {
        self.field = field
        self.order = order
        let reducedA = FE.fromValue(A, field: field)
        let reducedB = FE.fromValue(B, field: field)
        if reducedA.isZero {
            self.aIsZero = true
        }
        if reducedB.isZero {
            self.bIsZero = true
        }
        self.A = reducedA
        self.B = reducedB
    }
    
    //    public func testGenerator(_ p: AffineCoordinates) -> Bool {
    //        if p.isInfinity {
    //            return false
    //        }
    //        let reducedGeneratorX = FE.fromValue(p.X, field: self.field)
    //        let reducedGeneratorY = FE.fromValue(p.Y, field: self.field)
    //        let generatorPoint = AffineType(reducedGeneratorX, reducedGeneratorY, self)
    //        if !checkOnCurve(generatorPoint) {
    //            return false
    //        }
    //        if !self.mul(self.order, generatorPoint).isInfinity {
    //            return false
    //        }
    //        //        self.generator = generatorPoint
    //        return true
    //    }
    
    public func checkOnCurve(_ p: AffineType) -> Bool {
        if p.isInfinity {
            return false
        }
        let lhs = p.rawY * p.rawY // y^2
        var rhs = p.rawX * p.rawX * p.rawX
        if !self.aIsZero {
            rhs = rhs + self.A * p.rawX // x^3 + a*x
        }
        if !self.bIsZero {
            rhs = rhs + self.B // x^3 + a*x + b
        }
        return lhs == rhs
    }
    
    //    public func toPoint(_ x: BigUInt, _ y: BigUInt) -> AffineType? {
    //        return toPoint(AffineCoordinates(x, y))
    //    }
    //
    //    public func toPoint(_ p: AffineCoordinates) -> AffineType? {
    //        let reducedX = FE.fromValue(p.X, field: self.field)
    //        let reducedY = FE.fromValue(p.Y, field: self.field)
    //        let point = AffineType(reducedX, reducedY, self)
    //        if !checkOnCurve(point) {
    //            return nil
    //        }
    //        return point
    //    }
    
    //    public func hashInto(_ data: Data) -> AffineType {
    //        let bn = RawType(data)
    //        precondition(bn != nil)
    //        var seed = FE.fromValue(bn!, field: self.field)
    //        let ONE = self.ONE
    //        for _ in 0 ..< 100 {
    //            let x = seed
    //            var y2 = x * x * x
    //            if !self.aIsZero {
    //                y2 = y2 + self.A * x
    //            }
    //            if !self.bIsZero {
    //                y2 = y2 + self.B
    //            }
    //            // TODO
    //            let yReduced = y2.sqrt()
    //            if y2 == yReduced * yReduced {
    //                return AffineType(x, yReduced, self)
    //            }
    //            seed = seed + ONE
    //        }
    //        precondition(false, "Are you using a normal curve?")
    //        return ProjectiveType.infinityPoint(self).toAffine()
    //    }
    
    public func add(_ p: ProjectiveType, _ q: ProjectiveType) -> ProjectiveType {
        if p.isInfinity {
            return q
        }
        if q.isInfinity {
            return p
        }
        
        let pz2 = p.rawZ * p.rawZ// Pz^2
        let pz3 = p.rawZ * pz2 // Pz^3
        let qz2 = q.rawZ * q.rawZ // Pz^2
        let qz3 = q.rawZ * qz2 // Pz^3
        let u1 = p.rawX * qz2 // U1 = X1*Z2^2
        let s1 = p.rawY * qz3 // S1 = Y1*Z2^3
        let u2 = q.rawX * pz2 // U2 = X2*Z1^2
        let s2 = q.rawY * pz3 // S2 = Y2*Z1^3
        // Pu, Ps, Qu, Qs
        if u1 == u2 { // U1 == U2
            if s1 != s2 { // S1 != S2
                return ProjectiveType.infinityPoint(self)
            }
            else {
                return double(p)
            }
        }
        let h = u2 - u1 // U2 - U1
        let r = s2 - s1 // S2 - S1
        let h2 = h * h // h^2
        let h3 = h2 * h // h^3
        var rx = r * r // r^2
        rx = rx - h3 // r^2 - h^3
        let uh2 = u1 * h2 // U1*h^2
        let TWO = self.TWO
        rx = rx - (TWO * uh2) // r^2 - h^3 - 2*U1*h^2
        var ry = uh2 - rx // U1*h^2 - rx
        ry = r * ry // r*(U1*h^2 - rx)
        ry = ry - (s1 * h3) // R*(U1*H^2 - X3) - S1*H^3
        let rz = h * p.rawZ * q.rawZ // H*Z1*Z2
        return ProjectiveType(rx, ry, rz, self)
    }
    
    public func neg(_ p: ProjectiveType) -> ProjectiveType {
        return ProjectiveType(p.rawX, p.rawY.negate(), p.rawZ, self)
    }
    
    public func sub(_ p: ProjectiveType, _ q: ProjectiveType) -> ProjectiveType {
        return self.add(p, neg(q))
    }
    
    public func double(_ p: ProjectiveType) -> ProjectiveType {
        if p.isInfinity {
            return ProjectiveType.infinityPoint(self)
        }
        
        let px = p.rawX
        let py = p.rawY
        let py2 = py * py
        let FOUR = self.FOUR
        let THREE = self.THREE
        var s = FOUR * px
        s = s * py2
        var m = THREE * px
        m = m * px
        if !self.aIsZero {
            let z2 = p.rawZ * p.rawZ
            m = m + z2 * z2 * self.A // m = m + z^4*A
        }
        let qx = m * m - s - s // m^2 - 2*s
        let TWO = self.TWO
        let EIGHT = self.EIGHT
        let qy = m * (s - qx) - (EIGHT * py2 * py2)
        let qz = TWO * py * p.rawZ
        return ProjectiveType(qx, qy, qz, self)
    }
    
    public func mixedAdd(_ p: ProjectiveType, _ q: AffineType) -> ProjectiveType {
        if p.isInfinity {
            return q.toProjective()
        }
        if q.isInfinity {
            return p
        }
        
        let pz2 = p.rawZ * p.rawZ // Pz^2
        let pz3 = p.rawZ * pz2 // Pz^3
        
        let u1 = p.rawX // U1 = X1*Z2^2
        let s1 = p.rawY // S1 = Y1*Z2^3
        let u2 = q.rawX * pz2 // U2 = X2*Z1^2
        let s2 = q.rawY * pz3 // S2 = Y2*Z1^3
        if u1 == u2 {
            if s1 != s2 {
                return ProjectiveType.infinityPoint(self)
            }
            else {
                return double(p)
            }
        }
        let h = u2 - u1
        let r = s2 - s1 // S2 - S1
        let h2 = h * h // h^2
        let h3 = h2 * h// h^3
        var rx = r * r // r^2
        rx = rx - h3 // r^2 - h^3
        let uh2 = u1 * h2 // U1*h^2
        let TWO = self.TWO
        rx = rx - (TWO * uh2) // r^2 - h^3 - 2*U1*h^2
        var ry = uh2 - rx // U1*h^2 - rx
        ry = r * ry // r*(U1*h^2 - rx)
        ry = ry - (s1 * h3) // R*(U1*H^2 - X3) - S1*H^3
        let rz = h * p.rawZ // H*Z1*Z2
        return ProjectiveType(rx, ry, rz, self)
    }
    
    //    public func mul(_ scalar: BigUInt, _ p: AffinePoint) -> ProjectivePoint {
    //        return wNAFmul(scalar, p)
    //    }
    
    //    public func mul(_ scalar: GeneralFieldElement, _ p: AffineType) -> ProjectiveType {
    //        return wNAFmul(scalar.value, p)
    //    }
    
    //    public func mul(_ scalar: BigNumber, _ p: AffineType) -> ProjectiveType {
    //        return wNAFmul(scalar, p)
    //    }
    
    //    public func mul<U>(_ scalar: FieldElement<U>, _ p: AffineType) -> ProjectiveType {
    //        let nativeScalar = scalar.nativeValue
    //        if nativeScalar is UnderlyingRawType {
    //            return doubleAndAddMul(nativeScalar as! UnderlyingRawType, p)
    //        } else {
    //            let a = Field.f
    //            let thisNative = T.fromBytes(nativeScalar.bytes).nativeValue
    //            return doubleAndAddMul(thisNative as! UnderlyingRawType, p)
    //        }
    //    }
    //
    //    public func mul(_ scalar: BytesRepresentable, _ p: AffineType) -> ProjectiveType {
    //        let thisNative = T.fromBytes(scalar.bytes).nativeValue
    //        return doubleAndAddMul(thisNative as! UnderlyingRawType, p)
    //    }
    
    public func mul(_ scalar: ScalarType, _ p: AffineType) -> ProjectiveType {
        return doubleAndAddMul(scalar, p)
        //        return wNAFmul(scalar, p)
    }
    
    func doubleAndAddMul(_ scalar: ScalarType, _ p: AffineType) -> ProjectiveType {
        var base = p.toProjective()
        var result = ProjectiveType.infinityPoint(self)
        let bitwidth = scalar.bitWidth
        for i in 0 ..< bitwidth {
            if scalar.bit(i) {
                result = self.add(result, base)
            }
            if i == scalar.bitWidth - 1 {
                break
            }
            base = self.double(base)
        }
        return result
    }
    
    //    func wNAFmul(_ scalar: RawType, _ p: AffineType, windowSize: Int = DefaultWindowSize) -> ProjectiveType {
    //        if scalar.isZero {
    //            return ProjectiveType.infinityPoint(self)
    //        }
    //        if p.isInfinity {
    //            return ProjectiveType.infinityPoint(self)
    //        }
    //        let reducedScalar = scalar.mod(self.order)
    //        let projectiveP = p.toProjective()
    //        let numPrecomputedElements = (1 << (windowSize-2)) // 2**(w-1) precomputations required
    //        var precomputations = [ProjectiveType]() // P, 3P, 5P, 7P, 9P, 11P, 13P, 15P ...
    //        precomputations.append(projectiveP)
    //        let dbl = double(projectiveP)
    //        precomputations.append(mixedAdd(dbl, p))
    //        for i in 2 ..< numPrecomputedElements {
    //            precomputations.append(add(precomputations[i-1], dbl))
    //        }
    //        let lookups = computeWNAF(scalar: reducedScalar, windowSize: windowSize)
    //        var result = ProjectiveType.infinityPoint(self)
    //        let range = (0 ..< lookups.count).reversed()
    //        for i in range {
    //            result = double(result)
    //            let lookup = lookups[i]
    //            if lookup == 0 {
    //                continue
    //            } else if lookup > 0 {
    //                let idx = lookup >> 1
    //                let precomputeToAdd = precomputations[idx]
    //                result = add(result, precomputeToAdd)
    //            } else if lookup < 0 {
    //                let idx = -lookup >> 1
    //                let precomputeToAdd = neg(precomputations[idx])
    //                result = add(result, precomputeToAdd)
    //            }
    //        }
    //        return result
    //    }
}

public struct ExtendableAffinePoint<T>: AffinePointProtocol3 where T: CurveProtocol3 {
    public typealias ProjectiveType = ExtendableProjectivePoint<T>
    public typealias Curve = T
    public typealias FE = T.FE
    public typealias RawType = T.Field.RawType
    public typealias SelfType = ExtendableAffinePoint<T>
    
    //    public var description: String {
    //        return self.coordinates.description
    //    }
    
    public var curve: Curve
    public var isInfinity: Bool = true
    public var rawX: FE
    public var rawY: FE
    public var X: RawType {
        return self.rawX.value
    }
    public var Y: RawType {
        return self.rawY.value
    }
    
    //    public var coordinates: AffineCoordinates {
    //        if !self.isInfinity {
    //            return AffineCoordinates(BigUInt(self.rawX.bytes), BigUInt(self.rawY.bytes))
    //        } else {
    //            var p = AffineCoordinates(0, 0)
    //            p.setInfinity()
    //            return p
    //        }
    //    }
    
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
    
    public func isEqualTo(_ other: SelfType) -> Bool {
        return self.rawX == other.rawX && self.rawY == other.rawY
    }
    
    public static func == (lhs: SelfType, rhs: SelfType) -> Bool {
        return lhs.isEqualTo(rhs)
    }
    
    //    public static func *<U> (lhs: U, rhs: AffinePoint<T>) -> ProjectiveType where U: FiniteFieldCompatible {
    //        return rhs.curve.mul(lhs, rhs)
    //    }
    //
    //    public static func + (lhs: T.AffineType, rhs: T.AffineType) -> ProjectiveType {
    //        return lhs.curve.mixedAdd(lhs.toProjective(), rhs)
    //    }
}

public struct ExtendableProjectivePoint<T>: ProjectivePointProtocol3 where T: CurveProtocol3 {
    // also refered as Jacobian Point
    public typealias Curve = T
    public typealias FE = T.FE
    public typealias AffineType = ExtendableAffinePoint<T>
    public typealias RawType = T.Field.RawType
    public typealias SelfType = ExtendableProjectivePoint<T>
    
    public var curve: Curve
    
    public var isInfinity: Bool {
        return self.rawZ.isZero
    }
    public var rawX: FE
    public var rawY: FE
    public var rawZ: FE
    
    public static func infinityPoint<U>(_ curve: U) -> ExtendableProjectivePoint<U> where U: CurveProtocol3 {
        let field = curve.field
        let zero = U.FE.zeroElement(field)
        let one = U.FE.identityElement(field)
        return ExtendableProjectivePoint<U>(zero, one, zero, curve)
    }
    
    public func isEqualTo(_ other: SelfType) -> Bool {
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
    
    public static func == (lhs: SelfType, rhs: SelfType) -> Bool {
        return lhs.isEqualTo(rhs)
    }
    
    //    public static func + (lhs: ProjectivePoint<T>, rhs: ProjectivePoint<T>) -> ProjectivePoint<T> {
    //        return lhs.curve.add(lhs, rhs)
    //    }
    //
    //    public static func - (lhs: ProjectivePoint<T>, rhs: ProjectivePoint<T>) -> ProjectivePoint<T> {
    //        return lhs.curve.sub(lhs, rhs)
    //    }
    //
    //    public static func * (lhs: FiniteFieldCompatible, rhs: ProjectivePoint<T>) -> ProjectivePoint<T> {
    //        if rhs.isInfinity {
    //            return rhs
    //        }
    //        return rhs.curve.mul(lhs, rhs.toAffine())
    //    }
    //
    //    public static func + (lhs: ProjectivePoint<T>, rhs: AffinePoint<T>) -> ProjectivePoint<T> {
    //        return lhs.curve.mixedAdd(lhs, rhs)
    //    }
}

