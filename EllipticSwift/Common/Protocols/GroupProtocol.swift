//
//  GroupProtocol.swift
//  EllipticSwift
//
//  Created by Alex Vlasov on 24.09.2018.
//  Copyright © 2018 Alex Vlasov. All rights reserved.
//

import Foundation


public protocol GroupElement: Equatable {
    associatedtype Group
    associatedtype ScalarValue
    
    static func == (lhs: Self, rhs: Self) -> Bool
    static func + (lhs: Self, rhs: Self) -> Self
    static func - (lhs: Self, rhs: Self) -> Self
    static func * (lhs: ScalarValue, rhs: Self) -> Self
    static prefix func - (rhs: Self) -> Self
}
