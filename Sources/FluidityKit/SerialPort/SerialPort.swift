//
//  SerialPort.swift
//  FluidityKit
//
//  Created by Amano Fuon on 2024/12/15.
//

import Foundation

/// Universal serial port metadata type used across FluidityKit and Fluidity.
public struct SerialPortMeta {
    /// The device path of  this serial port.
    public let portPath: String
    
    /// Whether the serial port is related to a USB controller.
    public let hasUSBController: Bool
    
    /// The vendor ID of the USB controller (if it has one) related to this serial port.
    public let vendorID: String?
    
    /// The vendor name of the USB controller (if it has one) related to this serial port.
    public let vendorName: String?
    
    /// The product ID of the USB controller (if it has one) related to this serial port.
    public let productID: String?
    
    /// The product name of the USB controller (if it has one) related to this serial port.
    public let productName: String?
    
    /// The location ID of the USB controller (if it has one) related to this serial port.
    public let locationID: String?
}

/// Serial Port options type used across FluidityKit and Fluidity
public struct SerialPortOptions {
    /// The baud rate used to communicate from remote to host (receive)
    public let rxBaudRate: BaudRate
    
    /// The baud rate used to communicate from host to remote (send)
    public let txBaudRate: BaudRate
    
    /// The parity bit setting used to communicate between TX and RX
    public let parityBit: ParityBit
}

/// Centered Serial Port instance for device setting and data transmission.
public class SerialPort {
    let metadata: SerialPortMeta
    var port: Int32?
    
    public enum SerialPortError: Error {
        case invalidSerialPortPath
        case invalidTransmissionDirection
        case failedToOpenSerialPort
    }
    
    /// Create a Serial Port instance from given metadatas.
    public init(from: SerialPortMeta) {
        self.metadata = from
    }
    
    /// Get the port path from metadata.
    private func getPortPath() -> String {
        return metadata.portPath
    }
    
    /// Open serial port connection with receive and transmit enabled
    public func openPort() throws {
        try openPort(enableRX: true, enableTX: true)
    }
    
    /// Open serial port connection.
    public func openPort(enableRX rx: Bool, enableTX tx: Bool) throws {
        guard !getPortPath().isEmpty else {
            throw SerialPortError.invalidSerialPortPath
        }
        
        guard rx || tx else {
            throw SerialPortError.invalidTransmissionDirection
        }
        
        var flag: Int32
        
        if rx && tx {
            flag = O_RDWR
        } else if rx {
            flag = O_RDONLY
        } else if tx {
            flag = O_WRONLY
        } else {
            throw SerialPortError.invalidTransmissionDirection
        }
        
        port = Darwin.open(getPortPath(), flag)
        
        guard port != -1 else {
            throw SerialPortError.failedToOpenSerialPort
        }
    }
    
    /// Set the options to resolve and send serial port data
    public func setOptions() {
        // @todo
    }
}
