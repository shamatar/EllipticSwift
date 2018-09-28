//
//  File.swift
//  EllipticSwift
//
//  Created by Alex Vlasov on 24.09.2018.
//  Copyright © 2018 Alex Vlasov. All rights reserved.
//

import Foundation

public protocol Serializable {
    init(_ bytes: Data)
    var bytes: Data {get set}
}

public protocol Arithmetics: Equatable {
    associatedtype Field: FiniteFieldProtocol
    associatedtype RawType where RawType == Field.RawType
    
    static func == (lhs: Self, rhs: Self) -> Bool
    static func + (lhs: Self, rhs: Self) -> Self
    static func - (lhs: Self, rhs: Self) -> Self
    static func * (lhs: Self, rhs: Self) -> Self
    static prefix func - (rhs: Self) -> Self
    var isZero: Bool {get}
    func inv() -> Self
    func negate() -> Self
    var field: Field {get}
    var zero: Self {get}
    var one: Self {get}
    var value: RawType {get}
    var bytes: Data {get}
    static func identityElement(_ field: Field) -> Self
    static func zeroElement(_ field: Field) -> Self
    static func fromValue(_ a: RawType, field: Field) -> Self
    
//    static func / (lhs: Self, rhs: Self) -> (Self, Self)
}
