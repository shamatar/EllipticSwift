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
extension TinyUInt512 : Numeric {
    
    public static func +(lhs: TinyUInt512, rhs: TinyUInt512) -> TinyUInt512 {
        
        if ~lhs < rhs {
            exit(0) // overflow
        }
        let result = lhs.addingReportingOverflow(rhs)
        return result.partialValue
    }
    
    public static func +=(lhs: inout TinyUInt512, rhs: TinyUInt512) {
        lhs = lhs + rhs
    }
    
    public static func -(lhs: TinyUInt512, rhs: TinyUInt512) -> TinyUInt512 {
        
        if lhs < rhs {
            exit(0) // result cant be minus signed
        }
        
        let result = lhs.subtractingReportingOverflow(rhs)
        return result.partialValue
    }
    
    public static func -=(lhs: inout TinyUInt512, rhs: TinyUInt512) {
        lhs = lhs - rhs
    }
    
    public static func *(lhs: TinyUInt512, rhs: TinyUInt512) -> TinyUInt512 {
        
        let result = lhs.multipliedReportingOverflow(by: rhs)
        
        if result.overflow {
            exit(0) // overflow
        }
        
        return result.partialValue
    }
    
    public static func *=(lhs: inout TinyUInt512, rhs: TinyUInt512) {
        lhs = lhs * rhs
    }
}
