//
//  SerialPort.swift
//  FluidityKit
//
//  Created by Amano Fuon on 2024/12/15.
//

/// Universal serial port metadata type used across FluidityKit and Fluidity.
public struct SerialPortMeta {
    /// The device path of  this serial port.
    public let portPath: String
    
    /// Whether the serial port is related to a USB controller.
    public let hasUSBController: Bool
    
    /// The vendor ID of the USB controller (if it has one) related to this serial port.
    public let vendorID: Int?
    
    /// The vendor name of the USB controller (if it has one) related to this serial port.
    public let vendorName: String?
    
    /// The product ID of the USB controller (if it has one) related to this serial port.
    public let productID: Int?
    
    /// The product name of the USB controller (if it has one) related to this serial port.
    public let productName: String?
    
    /// The serial number of the USB controller (if it has one) related to this serial port.
    public let serialNumber: String?
    
    /// The location ID of the USB controller (if it has one) related to this serial port.
    public let locationID: Int?
}
