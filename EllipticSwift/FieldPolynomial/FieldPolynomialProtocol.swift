//
//  FieldPolynomialProtocol.swift
//  EllipticSwift
//
//  Created by Alex Vlasov on 24.09.2018.
//  Copyright © 2018 Alex Vlasov. All rights reserved.
//

import Foundation
import BigInt

public protocol FieldPolynomialProtocol {
    associatedtype Field
    associatedtype FieldElement: PrimeFieldElementProtocol where FieldElement.Field == Field
    
    var field: Field {get}
    var coefficients: [FieldElement] {get}
    var degree: Int {get}
    var isZero: Bool {get}
    
    init(_ coefficients: [BytesRepresentable], field: Field)
    init(_ coefficients: [Field.UnderlyingRawType], field: Field)
    init(_ coefficients: [FieldElement])
    init(field: Field)
    
    func add(_ p: Self) -> Self
    func sub(_ p: Self) -> Self
    func mul(_ p: Self) -> Self
    func div(_ p: Self) -> (Self, Self)
    func neg() -> Self
    func equals(_ other: Self) -> Bool
    func evaluate(_ x: FieldElement) -> FieldElement
    
}
