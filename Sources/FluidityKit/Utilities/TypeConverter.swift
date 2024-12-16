//
//  TypeConverter.swift
//  FluidityKit
//
//  Created by Amano Fuon on 2024/12/16.
//

import Foundation

enum TypeConverterError: Error {
    case invalidNSCFNumber
}

/// Internal function to convert string type with force conversion
func convertNSCFNumberToHexString(_ original: Any) throws -> String {
    let resolved = original as? NSNumber
    guard let intValue = resolved?.intValue else {
        throw TypeConverterError.invalidNSCFNumber
    }
    return String(intValue, radix: 16)
}
