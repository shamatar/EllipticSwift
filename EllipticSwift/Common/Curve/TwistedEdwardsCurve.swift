//
//  TwistedEdwardsCurve.swift
//  EllipticSwift
//
//  Created by Alex Vlasov on 21.09.2018.
//  Copyright © 2018 Alex Vlasov. All rights reserved.
//

import Foundation
import BigInt

public class TwistedEdwardsCurve<T>: CurveProtocol where T: PrimeFieldProtocol {
    public typealias Field = T
    public typealias FE = PrimeFieldElement<T>
    public typealias UnderlyingRawType = T.UnderlyingRawType
    public typealias AffineType = AffinePoint<TwistedEdwardsCurve<T>>
    public typealias ProjectiveType = ProjectivePoint<TwistedEdwardsCurve<T>>
    public var field: T
    public var order: UnderlyingRawType
    public var curveOrderField: T
    public var A: FE
    public var D: FE
    
    
    public init(field: T, order: UnderlyingRawType, A: UnderlyingRawType, D: UnderlyingRawType) {
        self.field = field
        self.order = order
        precondition(!A.isZero)
        precondition(!D.isZero)
        precondition(A != D)
        let reducedA = FE.fromValue(A, field: field)
        let reducedD = FE.fromValue(D, field: field)
        self.A = reducedA
        self.D = reducedD
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
        var lhs = self.A * p.rawX * p.rawX // a*x^2
        lhs = lhs + p.rawY * p.rawY
        let rhs = FE.identityElement(self.field) + self.D * p.rawX * p.rawX * p.rawY * p.rawY
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
        precondition(false)
        return ProjectiveType.infinityPoint(self).toAffine()
//        let bn = UnderlyingRawType(data)
//        precondition(bn != nil)
//        var seed = FE.fromValue(bn!, field: self.field)
//        let ONE = FE.identityElement(field)
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
    }
    
    public func add(_ p: ProjectiveType, _ q: ProjectiveType) -> ProjectiveType {
        if p.isInfinity {
            return q
        }
        if q.isInfinity {
            return p
        }
        precondition(p.rawZ == q.rawZ)
        let field = self.field
        let ONE = FE.identityElement(field)
        let mulComb = self.D * p.rawX * p.rawY * q.rawX * q.rawY
        let x_top = p.rawX * q.rawY + q.rawX * p.rawY
        let x_bot = ONE + mulComb
        let y_top = p.rawY * q.rawY - self.A * p.rawX * q.rawX
        let y_bot = ONE - mulComb
        let x = x_top * (x_bot.inv())
        let y = y_top * (y_bot.inv())
        return ProjectiveType(x, y, p.rawZ, self)
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
        let field = self.field
        let ONE = FE.identityElement(field)
        let TWO = FE.fromValue(UInt64(2), field: field)
        let xSquared = p.rawX * p.rawX
        let ySquared = p.rawY * p.rawY
        let mulComb = self.D * ySquared * xSquared
        let x_top = TWO * p.rawX * p.rawY
        let x_bot = ONE + mulComb
        let y_top = ySquared - self.A * xSquared
        let y_bot = ONE - mulComb
        let x = x_top * (x_bot.inv())
        let y = y_top * (y_bot.inv())
        return ProjectiveType(x, y, p.rawZ, self)
    }
    
    public func mixedAdd(_ p: ProjectiveType, _ q: AffineType) -> ProjectiveType {
        if p.isInfinity {
            return q.toProjective()
        }
        if q.isInfinity {
            return p
        }
        let field = self.field
        let ONE = FE.identityElement(field)
        let mulComb = self.D * p.rawX * p.rawY * q.rawX * q.rawY
        let x_top = p.rawX * q.rawY + q.rawX * p.rawY
        let x_bot = ONE + mulComb
        let y_top = p.rawY * q.rawY - self.A * p.rawX * q.rawX
        let y_bot = ONE - mulComb
        let x = x_top * (x_bot.inv())
        let y = y_top * (y_bot.inv())
        return ProjectiveType(x, y, p.rawZ, self)
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
            if i == scalar.bitWidth - 1 {
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
        let reducedScalar = scalar.mod(self.order)
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
