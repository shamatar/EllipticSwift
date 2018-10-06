//
//  TinyUInt512Hashable.swift
//  tiny-bigint-swift
//
//  Created by Антон Григорьев on 04.08.2018.
//  Copyright © 2018 BaldyAsh. All rights reserved.
//

/*
 * - Extension for conforming Hashable (for BinaryInteger conforming)
 */
extension TinyUInt1024 : Hashable {
    public var hashValue: Int {
        return self.storage.secondHalf.hashValue ^ self.storage.firstHalf.hashValue
    }
}
