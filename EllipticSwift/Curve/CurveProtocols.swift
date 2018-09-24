//
//  CurveProtocol.swift
//  EllipticSwift
//
//  Created by Alexander Vlasov on 02.08.2018.
//  Copyright © 2018 Alexander Vlasov. All rights reserved.
//

import Foundation
import BigInt

public protocol CurveProtocol {
    associatedtype Field
    associatedtype FieldElement: PrimeFieldElementProtocol where FieldElement.Field == Field
    
    associatedtype AffineType: AffinePointProtocol
    associatedtype ProjectiveType: ProjectivePointProtocol
    
    var field: Field {get}
    var order: Field.UnderlyingRawType {get}
    var curveOrderField: Field {get}
//    var generator: AffineType? {get}
    
    func checkOnCurve(_ p: AffineType) -> Bool
    func add(_ p: ProjectiveType, _ q: ProjectiveType) -> ProjectiveType
    func sub(_ p: ProjectiveType, _ q: ProjectiveType) -> ProjectiveType
    func mixedAdd(_ p: ProjectiveType, _ q: AffineType) -> ProjectiveType
//    func mul(_ scalar: BigNumber, _ p: AffineType) -> ProjectiveType
//    func mul(_ scalar: BigUInt, _ p: AffineType) -> ProjectiveType
//    func mul<U>(_ scalar: PrimeFieldElement<U>, _ p: AffineType) -> ProjectiveType
//    func mul(_ scalar: BytesRepresentable, _ p: AffineType) -> ProjectiveType
    func mul(_ scalar: Field.UnderlyingRawType, _ p: AffineType) -> ProjectiveType
    func neg(_ p: ProjectiveType) -> ProjectiveType
    func hashInto(_ data: Data) -> AffineType
    func testGenerator(_ p: AffineCoordinates) -> Bool
}

public protocol AffinePointProtocol {
    associatedtype Curve: CurveProtocol
    associatedtype ProjectiveType: ProjectivePointProtocol where ProjectiveType.Curve == Curve
    var curve: Curve {get}
    var isInfinity: Bool {get}
    var rawX: Curve.FieldElement {get}
    var rawY: Curve.FieldElement {get}
    var X: Curve.Field.UnderlyingRawType {get}
    var Y: Curve.Field.UnderlyingRawType {get}
    
    var coordinates: AffineCoordinates {get}
    
    func isEqualTo(_ other: Self) -> Bool
    
    init(_ rawX: Curve.FieldElement, _ rawY: Curve.FieldElement, _ curve: Curve)
    
    func toProjective() -> ProjectiveType
}

public protocol ProjectivePointProtocol {
    associatedtype Curve
    associatedtype AffineType: AffinePointProtocol where AffineType.Curve == Curve
    var curve: Curve {get}
    
    var isInfinity: Bool {get}
    var rawX: Curve.FieldElement {get}
    var rawY: Curve.FieldElement {get}
    var rawZ: Curve.FieldElement {get}
    
    static func infinityPoint(_ curve: Curve) -> Self
    
    func isEqualTo(_ other: Self) -> Bool
    
    init(_ rawX: Curve.FieldElement, _ rawY: Curve.FieldElement, _ rawZ: Curve.FieldElement, _ curve: Curve)
    
    func toAffine() -> AffineType
}
