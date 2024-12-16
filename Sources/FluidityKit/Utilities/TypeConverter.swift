//
//  TypeConverter.swift
//  FluidityKit
//
//  Created by Amano Fuon on 2024/12/16.
//

import Foundation

/// Internal function to convert string type with force conversion
func convertNSCFNumberToHexString(_ original: Any) throws -> String {
    let resolved = original as? NSNumber
    guard let intValue = resolved?.intValue else {
        throw SerialPortDetector.DetectorError.invalidPropertyID
    }
    return String(intValue, radix: 16)
}
