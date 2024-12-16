//
//  USBIDs.swift
//  FluidityKit
//
//  Created by Amano Fuon on 2024/12/15.
//

import Foundation

struct USBEntry: Codable {
    let vendorID: String
    let vendorName: String
    let devices: [USBDevice]?
    
    struct USBDevice: Codable {
        let productID: String
        let productName: String
    }
}

struct USBName {
    public let vendorName: String?
    public let productName: String?
}

class USBIDs {
    var data: [USBEntry]
    
    enum USBIDsFinderError: Error {
        case couldNotResolveData
    }
    
    /// Create a USBIDs instance from data source optionally.
    init(from jsonData: Data? = nil) throws {
        var sourceData = Data()
        if let jsonData = jsonData {
            sourceData = jsonData
        }
        data = []
        try loadSource(jsonData: sourceData)
    }
    
    /// Load data source for USB IDs matching.
    func loadSource(jsonData: Data) throws {
        let decoder = JSONDecoder()
        do {
            let entries = try decoder.decode([USBEntry].self, from: jsonData)
            self.data = entries
        } catch {
            throw USBIDsFinderError.couldNotResolveData
        }
    }
    
    /// Get the property names related to the given IDs.
    func query(vendorID: String, productID: String?) -> USBName {
        var vendorName: String?
        var productName: String?
        for entry in self.data {
            if entry.vendorID == vendorID {
                vendorName = entry.vendorName
                if let devices = entry.devices {
                    for device in devices {
                        if (device.productID == productID) {
                            productName = device.productName
                        }
                    }
                }
            }
        }
        return USBName(vendorName: vendorName, productName: productName)
    }
}
