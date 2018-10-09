//
//  CurveOverArithmericsProtocol.swift
//  EllipticSwift
//
//  Created by Alex Vlasov on 28/09/2018.
//  Copyright © 2018 Alex Vlasov. All rights reserved.
//

import Foundation
import BigInt

//public protocol CurveProtocol2 {
//
//    associatedtype Field // FiniteFieldProtocol
//    associatedtype FE: Arithmetics where FE.Field == Field
//    associatedtype RawType
//    associatedtype ScalarType: BitsAndBytes
//
//    associatedtype AffineType: AffinePointProtocol2
//    associatedtype ProjectiveType: ProjectivePointProtocol2
//
//    var order: ScalarType {get}
//    var field: Field {get}
//
////    func checkOnCurve(_ p: AffineType) -> Bool
//    func add(_ p: ProjectiveType, _ q: ProjectiveType) -> ProjectiveType
//    func sub(_ p: ProjectiveType, _ q: ProjectiveType) -> ProjectiveType
//    func mixedAdd(_ p: ProjectiveType, _ q: AffineType) -> ProjectiveType
//    //    func mul<U>(_ scalar: FieldElement<U>, _ p: AffineType) -> ProjectiveType
//    //    func mul(_ scalar: BytesRepresentable, _ p: AffineType) -> ProjectiveType
//    func mul(_ scalar: ScalarType, _ p: AffineType) -> ProjectiveType
//    func neg(_ p: ProjectiveType) -> ProjectiveType
////    func hashInto(_ data: Data) -> AffineType
////    func testGenerator(_ p: AffineCoordinates) -> Bool
//}
//
//
//public protocol AffinePointProtocol2 {
//    associatedtype Curve: CurveProtocol2
//    associatedtype ProjectiveType: ProjectivePointProtocol2 where ProjectiveType.Curve == Curve
//
//    var curve: Curve {get}
//    var isInfinity: Bool {get}
//    var rawX: Curve.FE {get}
//    var rawY: Curve.FE {get}
//    var X: Curve.Field.RawType {get}
//    var Y: Curve.Field.RawType {get}
//
////    var coordinates: AffineCoordinates {get}
//
//    func isEqualTo(_ other: Self) -> Bool
//
//    init(_ rawX: Curve.FE, _ rawY: Curve.FE, _ curve: Curve)
//
//    func toProjective() -> ProjectiveType
//}
//
//
//
//public protocol ProjectivePointProtocol2 {
//    associatedtype Curve
//    associatedtype AffineType: AffinePointProtocol2 where AffineType.Curve == Curve
//    var curve: Curve {get}
//
//    var isInfinity: Bool {get}
//    var rawX: Curve.FE {get}
//    var rawY: Curve.FE {get}
//    var rawZ: Curve.FE {get}
//
//    static func infinityPoint(_ curve: Curve) -> Self
//
//    func isEqualTo(_ other: Self) -> Bool
//
//    init(_ rawX: Curve.FE, _ rawY: Curve.FE, _ rawZ: Curve.FE, _ curve: Curve)
//
//    func toAffine() -> AffineType
//}

public protocol CurveProtocol3 {
    
    associatedtype Field // FiniteFieldProtocol
    associatedtype FE: Arithmetics where FE.Field == Field
    associatedtype RawType
    associatedtype ScalarType: BitsAndBytes
    
    associatedtype AffineType: AffinePointProtocol3
    associatedtype ProjectiveType: ProjectivePointProtocol3
    
    var order: ScalarType {get}
    var field: Field {get}
    
    //    func checkOnCurve(_ p: AffineType) -> Bool
    func add(_ p: ProjectiveType, _ q: ProjectiveType) -> ProjectiveType
    func sub(_ p: ProjectiveType, _ q: ProjectiveType) -> ProjectiveType
    func mixedAdd(_ p: ProjectiveType, _ q: AffineType) -> ProjectiveType
    //    func mul<U>(_ scalar: FieldElement<U>, _ p: AffineType) -> ProjectiveType
    //    func mul(_ scalar: BytesRepresentable, _ p: AffineType) -> ProjectiveType
    func mul(_ scalar: ScalarType, _ p: AffineType) -> ProjectiveType
    func neg(_ p: ProjectiveType) -> ProjectiveType
    //    func hashInto(_ data: Data) -> AffineType
    //    func testGenerator(_ p: AffineCoordinates) -> Bool
}


public protocol AffinePointProtocol3 {
    associatedtype Curve: CurveProtocol3
    associatedtype ProjectiveType: ProjectivePointProtocol3 where ProjectiveType.Curve == Curve
    
    var curve: Curve {get}
    var isInfinity: Bool {get}
    var rawX: Curve.FE {get}
    var rawY: Curve.FE {get}
    var X: Curve.Field.RawType {get}
    var Y: Curve.Field.RawType {get}
    
    //    var coordinates: AffineCoordinates {get}
    
    func isEqualTo(_ other: Self) -> Bool
    
    init(_ rawX: Curve.FE, _ rawY: Curve.FE, _ curve: Curve)
    
    func toProjective() -> ProjectiveType
}

public protocol ProjectivePointProtocol3 {
    associatedtype Curve
    associatedtype AffineType: AffinePointProtocol3 where AffineType.Curve == Curve
    var curve: Curve {get}
    
    var isInfinity: Bool {get}
    var rawX: Curve.FE {get}
    var rawY: Curve.FE {get}
    var rawZ: Curve.FE {get}
    
    static func infinityPoint(_ curve: Curve) -> Self
    
    func isEqualTo(_ other: Self) -> Bool
    
    init(_ rawX: Curve.FE, _ rawY: Curve.FE, _ rawZ: Curve.FE, _ curve: Curve)
    
    func toAffine() -> AffineType
}
