//
//  TinyUInt512Numeric.swift
//  tiny-bigint-swift
//
//  Created by Антон Григорьев on 04.08.2018.
//  Copyright © 2018 BaldyAsh. All rights reserved.
//

import Darwin

/*
 * - Extension for conforming Numeric and use + += - -= * *=
 */
extension TinyUInt1024 : Numeric {
    
    public static func +(lhs: TinyUInt1024, rhs: TinyUInt1024) -> TinyUInt1024 {
        
        if ~lhs < rhs {
            exit(0) // overflow
        }
        let result = lhs.addingReportingOverflow(rhs)
        return result.partialValue
    }
    
    public static func +=(lhs: inout TinyUInt1024, rhs: TinyUInt1024) {
        lhs = lhs + rhs
    }
    
    public static func -(lhs: TinyUInt1024, rhs: TinyUInt1024) -> TinyUInt1024 {
        
        if lhs < rhs {
            exit(0) // result cant be minus signed
        }
        
        let result = lhs.subtractingReportingOverflow(rhs)
        return result.partialValue
    }
    
    public static func -=(lhs: inout TinyUInt1024, rhs: TinyUInt1024) {
        lhs = lhs - rhs
    }
    
    public static func *(lhs: TinyUInt1024, rhs: TinyUInt1024) -> TinyUInt1024 {
        
        let result = lhs.multipliedReportingOverflow(by: rhs)
        
        if result.overflow {
            exit(0) // overflow
        }
        
        return result.partialValue
    }
    
    public static func *=(lhs: inout TinyUInt1024, rhs: TinyUInt1024) {
        lhs = lhs * rhs
    }
}
