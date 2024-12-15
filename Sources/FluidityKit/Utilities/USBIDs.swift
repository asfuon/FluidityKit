//
//  USBIDs.swift
//  FluidityKit
//
//  Created by Amano Fuon on 2024/12/15.
//

import Foundation

struct USBEntry: Codable {
    let vendorID: Int
    let vendorName: String
    let devices: [USBDevice]
    
    struct USBDevice: Codable {
        let productID: Int
        let productName: String
    }
}

struct USBName {
    let vendorName: String?
    let productName: String?
}

class USBIDs {
    var data: [USBEntry]
    
    enum USBIDsFinderError: Error {
        case couldNotResolveData
    }
    
    init(from jsonData: Data) throws {
        let decoder = JSONDecoder()
        do {
            let entries = try decoder.decode([USBEntry].self, from: jsonData)
            self.data = entries
        } catch {
            throw USBIDsFinderError.couldNotResolveData
        }
    }
    
    func query(vendorID: Int, productID: Int?) -> USBName {
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
