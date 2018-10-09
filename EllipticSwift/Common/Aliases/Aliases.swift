//
//  Aliases.swift
//  EllipticSwift
//
//  Created by Alex Vlasov on 09/10/2018.
//  Copyright © 2018 Alex Vlasov. All rights reserved.
//

#if os(OSX)
import Accelerate
public typealias U256 = vU256
//public typealias U512 = vU512
//public typealias U1024 = vU1024
#elseif os(iOS)
public typealias U256 = NativeU256
//public typealias U512 = NativeU512
//public typealias U1024 = TinyUInt1024
#endif
