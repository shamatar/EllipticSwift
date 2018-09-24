//
//  ExtensionFieldProtocol.swift
//  EllipticSwift
//
//  Created by Alex Vlasov on 24.09.2018.
//  Copyright © 2018 Alex Vlasov. All rights reserved.
//

import Foundation

public protocol ExtensionFieldProtocol {
    associatedtype Field
    associatedtype FE: FieldElementProtocol where FE.Field == Field
    associatedtype ReductionPolynomial
    associatedtype ExtensionFieldElement
    associatedtype ScalarValue
    associatedtype RawType
    
    var field: Field {get}
    var degree: Int {get}
    var reducingPolynomial: ReductionPolynomial {get}
    
    func add(_ a: ExtensionFieldElement, _ b: ExtensionFieldElement) -> ExtensionFieldElement
    func sub(_ a: ExtensionFieldElement, _ b: ExtensionFieldElement) -> ExtensionFieldElement
    func neg(_ a: ExtensionFieldElement) -> ExtensionFieldElement
    func mul(_ a: ExtensionFieldElement, _ b: ExtensionFieldElement) -> ExtensionFieldElement
    func pow(_ a: ExtensionFieldElement, _ b: ScalarValue) -> ExtensionFieldElement
    func inv(_ a: ExtensionFieldElement) -> ExtensionFieldElement
    
    func fromValue(_ a: RawType) -> ExtensionFieldElement
    func toValue(_ a: ExtensionFieldElement) -> RawType
    
    var identityElement: ExtensionFieldElement {get}
    var zeroElement: ExtensionFieldElement {get}
}
