//
//  GeneralizedWeirstrassCurve.swift
//  EllipticSwift
//
//  Created by Alexander Vlasov on 02.08.2018.
//  Copyright © 2018 Alexander Vlasov. All rights reserved.
//

import Foundation
import BigInt

public class WeierstrassCurve<T>: CurveProtocol where T: PrimeFieldProtocol {
    public typealias Field = T
    public typealias FE = PrimeFieldElement<T>
    public typealias UnderlyingRawType = T.UnderlyingRawType
    public typealias AffineType = AffinePoint<WeierstrassCurve<T>>
    public typealias ProjectiveType = ProjectivePoint<WeierstrassCurve<T>>
    public var field: T
    public var order: UnderlyingRawType
    public var curveOrderField: T
    public var A: FE
    public var B: FE
    
    internal var aIsZero: Bool = false
    internal var bIsZero: Bool = false
    internal lazy var ONE: FE = { FE.identityElement(self.field) }()
    internal lazy var TWO: FE = { self.ONE + self.ONE }()
    internal lazy var THREE: FE = { self.TWO + self.ONE }()
    internal lazy var FOUR: FE = { self.TWO + self.TWO }()
    internal lazy var EIGHT: FE = { self.FOUR + self.FOUR }()

    
    public init(field: T, order: UnderlyingRawType, A: UnderlyingRawType, B: UnderlyingRawType) {
        self.field = field
        self.order = order
        let reducedA = FE.fromValue(A, field: field)
        let reducedB = FE.fromValue(B, field: field)
        if A.isZero {
            self.aIsZero = true
        }
        if B.isZero {
            self.bIsZero = true
        }
        self.A = reducedA
        self.B = reducedB
//        let FOUR: FE = FE.fromValue(UInt64(4), field: field)
//        var det = FOUR * self.A * self.A * self.A
//        let TWENTYSEVEN: FE = FE.fromValue(UInt64(27), field: field)
//        det = det + TWENTYSEVEN * self.B * self.B
//        precondition(!det.isZero, "Creating a curve with 0 determinant")
        self.curveOrderField = T(self.order)
    }
    
    public func testGenerator(_ p: AffineCoordinates) -> Bool {
        if p.isInfinity {
            return false
        }
        let reducedGeneratorX = FE.fromValue(p.X, field: self.field)
        let reducedGeneratorY = FE.fromValue(p.Y, field: self.field)
        let generatorPoint = AffineType(reducedGeneratorX, reducedGeneratorY, self)
        if !checkOnCurve(generatorPoint) {
            return false
        }
        if !self.mul(self.order, generatorPoint).isInfinity {
            return false
        }
//        self.generator = generatorPoint
        return true
    }

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

    public func toPoint(_ x: BigUInt, _ y: BigUInt) -> AffineType? {
        return toPoint(AffineCoordinates(x, y))
    }
    
    public func toPoint(_ p: AffineCoordinates) -> AffineType? {
        let reducedX = FE.fromValue(p.X, field: self.field)
        let reducedY = FE.fromValue(p.Y, field: self.field)
        let point = AffineType(reducedX, reducedY, self)
        if !checkOnCurve(point) {
            return nil
        }
        return point
    }
    
    public func hashInto(_ data: Data) -> AffineType {
        let bn = UnderlyingRawType(data)
        precondition(bn != nil)
        var seed = FE.fromValue(bn!, field: self.field)
        let ONE = self.ONE
        for _ in 0 ..< 100 {
            let x = seed
            var y2 = x * x * x
            if !self.aIsZero {
                y2 = y2 + self.A * x
            }
            if !self.bIsZero {
                y2 = y2 + self.B
            }
            // TODO
            let yReduced = y2.sqrt()
            if y2 == yReduced * yReduced {
                return AffineType(x, yReduced, self)
            }
            seed = seed + ONE
        }
        precondition(false, "Are you using a normal curve?")
        return ProjectiveType.infinityPoint(self).toAffine()
    }

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
    public func mul(_ scalar: BytesRepresentable, _ p: AffineType) -> ProjectiveType {
        guard let thisNative = UnderlyingRawType(scalar.bytes) else {
            return ProjectiveType.infinityPoint(self)
        }
        return mul(thisNative, p)
    }
    
    public func mul(_ scalar: UnderlyingRawType, _ p: AffineType) -> ProjectiveType {
//        return doubleAndAddMul(scalar, p)
        return wNAFmul(scalar, p)
    }
    
    func doubleAndAddMul(_ scalar: UnderlyingRawType, _ p: AffineType) -> ProjectiveType {
        var base = p.toProjective()
        var result = ProjectiveType.infinityPoint(self)
        let bitwidth = scalar.bitWidth
        for i in 0 ..< bitwidth {
            if scalar.bit(i) {
                result = self.add(result, base)
            }
            if i == bitwidth - 1 {
                break
            }
            base = self.double(base)
        }
        return result
    }
    
    func wNAFmul(_ scalar: UnderlyingRawType, _ p: AffineType, windowSize: Int = DefaultWindowSize) -> ProjectiveType {
        if scalar.isZero {
            return ProjectiveType.infinityPoint(self)
        }
        if p.isInfinity {
            return ProjectiveType.infinityPoint(self)
        }
//        let reducedScalar = scalar.mod(self.order)
        let reducedScalar = scalar
        let projectiveP = p.toProjective()
        let numPrecomputedElements = (1 << (windowSize-2)) // 2**(w-1) precomputations required
        var precomputations = [ProjectiveType]() // P, 3P, 5P, 7P, 9P, 11P, 13P, 15P ...
        precomputations.append(projectiveP)
        let dbl = double(projectiveP)
        precomputations.append(mixedAdd(dbl, p))
        for i in 2 ..< numPrecomputedElements {
            precomputations.append(add(precomputations[i-1], dbl))
        }
        let lookups = computeWNAF(scalar: reducedScalar, windowSize: windowSize)
        var result = ProjectiveType.infinityPoint(self)
        let range = (0 ..< lookups.count).reversed()
        for i in range {
            result = double(result)
            let lookup = lookups[i]
            if lookup == 0 {
                continue
            } else if lookup > 0 {
                let idx = lookup >> 1
                let precomputeToAdd = precomputations[idx]
                result = add(result, precomputeToAdd)
            } else if lookup < 0 {
                let idx = -lookup >> 1
                let precomputeToAdd = neg(precomputations[idx])
                result = add(result, precomputeToAdd)
            }
        }
        return result
    }
}
