//
//  Parity.swift
//  FluidityKit
//
//  Created by Amano Fuon on 2024/12/16.
//

import Foundation

/// Pre-defined ParityBit options
public enum ParityBit {
    case unset
    case odd
    case even
    
    var value: tcflag_t {
        switch self {
        case .unset:
            return 0
        case .odd:
            return tcflag_t(PARENB)
        case .even:
            return tcflag_t(PARENB | PARODD)
        }
    }
}
