//
//  USBIDs.swift
//  FluidityKit
//
//  Created by Amano Fuon on 2024/12/15.
//

import Foundation

public struct USBEntry: Codable {
    let vendorID: Int
    let vendorName: String
    let devices: [USBDevice]
    
    struct USBDevice: Codable {
        let productID: Int
        let productName: String
    }
}

public struct USBName {
    let vendorName: String?
    let productName: String?
}

public class USBIDs {
    var data: [USBEntry]
    
    public enum USBIDsFinderError: Error {
        case couldNotResolveData
    }
    
    public init(from jsonData: Data) throws {
        let decoder = JSONDecoder()
        do {
            let entries = try decoder.decode([USBEntry].self, from: jsonData)
            self.data = entries
        } catch {
            throw USBIDsFinderError.couldNotResolveData
        }
    }
    
    public func query(vendorID: Int, productID: Int?) -> USBName {
        var vendorName: String?
        var productName: String?
        for entry in self.data {
            if entry.vendorID == vendorID {
                vendorName = entry.vendorName
                for device in entry.devices {
                    if (device.productID == productID) {
                        productName = device.productName
                    }
                }
            }
        }
        return USBName(vendorName: vendorName, productName: productName)
    }
}
