//
//  Main.swift
//  FluidityKit
//
//  Created by Amano Fuon on 2024/12/16.
//

// Sample code for development real world testing

import Foundation
import FluidityKit
import IOKit

func main() throws {
    let ins = try SerialPortDetector()
    
    let result = try ins.discoverSerialPorts()
    
    for el in result {
        print("Port Path: \(el.portPath)")
        print("USB Controller: \(el.hasUSBController ? "Yes" : "No")")
        
        if let vid = el.vendorID {
            print("Vendor ID: \(vid)")
        }
        
        if let vn = el.vendorName {
            print("Vendor Name: \(vn)")
        }
        
        if let pid = el.productID {
            print("Product ID: \(pid)")
        }
        
        if let pn = el.productName {
            print("Product Name: \(pn)")
        }
    }
}

try main()
