//
//  ExtensionFieldProtocol.swift
//  EllipticSwift
//
//  Created by Alex Vlasov on 24.09.2018.
//  Copyright © 2018 Alex Vlasov. All rights reserved.
//

import Foundation

public protocol ExtensionFieldProtocol: FiniteFieldProtocol {
    associatedtype Field
    associatedtype ReductionPolynomial
    associatedtype PolynomialCoefficientType: Arithmetics where PolynomialCoefficientType.Field == Field
    
    var field: Field {get}
    var degree: Int {get}
    var reducingPolynomial: ReductionPolynomial {get}
}
