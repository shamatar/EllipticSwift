//
//  Data+Bytes.swift
//  EllipticSwift
//
//  Created by Alexander Vlasov on 07.08.2018.
//  Copyright © 2018 Alexander Vlasov. All rights reserved.
//

import Foundation

extension Data {
    public var bytes: [UInt8] {
        return Array(self)
    }
}
