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
    
    var matchedMeta: SerialPortMeta?
    
    for el in result {
        if (el.portPath == "/dev/cu.usbserial-1140") {
            matchedMeta = el
            break
        }
    }
    
    guard let matchedMeta = matchedMeta else {
        return
    }
    
    let portIns = try SerialPort(from: matchedMeta)
    
    try portIns.openPort()
    
    let payload = try portIns.readData(length: 10)
    
    print(payload)
}

try main()
