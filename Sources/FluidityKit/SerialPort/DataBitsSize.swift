//
//  DataBitSize.swift
//  FluidityKit
//
//  Created by Amano Fuon on 2024/12/17.
//

import Foundation

public enum DataBitsSize {
    case bits5
    case bits6
    case bits7
    case bits8

    var value: tcflag_t {
        switch self {
        case .bits5:
            return tcflag_t(CS5)
        case .bits6:
            return tcflag_t(CS6)
        case .bits7:
            return tcflag_t(CS7)
        case .bits8:
            return tcflag_t(CS8)
        }
    }
}
