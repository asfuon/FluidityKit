//
//  SerialPortDetector.swift
//  FluidityKit
//
//  Created by Amano Fuon on 2024/12/15.
//

import Foundation
import IOKit
import IOKit.serial

/// Detector to find all available serial ports on the current host (macOS only).
public class SerialPortDetector {
    private let idsFinder: USBIDs

    /// Custom Errors of the detector
    public enum DetectorError: Error {
        case serviceMatchingError
        case portPathDetectingError
        case portPathInvalid
        case deviceClassNameInvalid
        case jsonResolveError
        case failedToGetSerialPortIterator
    }
    
    public init() throws {
        // @todo custom sources
        guard let url = Bundle.module.url(forResource: "usb_ids", withExtension: "json"),
              let data = try? Data(contentsOf: url) else {
            throw DetectorError.jsonResolveError
        }
        self.idsFinder = try USBIDs(from: data)
    }
    
    /// Get the IO iterator of serial port.
    private func getSerialPortIterator() throws -> io_iterator_t {
        var serialPortIterator: io_iterator_t = 0
        
        guard let toBeMatched = IOServiceMatching(kIOSerialBSDServiceValue) else {
            throw DetectorError.serviceMatchingError
        }
        
        // convert the CFMutableDictionary to NS one
        let matchingDict = (toBeMatched as NSMutableDictionary)
        matchingDict[kIOSerialBSDTypeKey] = kIOSerialBSDAllTypes
        
        var matchingResult: kern_return_t
        
        if #available(macOS 12.0, *) {
            matchingResult = IOServiceGetMatchingServices(kIOMainPortDefault, matchingDict, &serialPortIterator)
        } else {
            matchingResult = IOServiceGetMatchingServices(kIOMasterPortDefault, matchingDict, &serialPortIterator)
        }
        
        if matchingResult != KERN_SUCCESS {
            throw DetectorError.serviceMatchingError
        }
        
        return serialPortIterator
    }
    
    /// Get device's class name from IO object
    private func getDeviceClassName(_ device: io_object_t) throws -> String {
        var className = [CChar](repeating: 0, count: 128)
        IOObjectGetClass(device, &className)
        
        guard let resolved = String(cString: className, encoding: String.Encoding.utf8) else {
            throw DetectorError.deviceClassNameInvalid
        }
        
        return resolved
    }
    
    /// Get device's properties from IO object
    private func getDeviceProperties(_ device: io_object_t) throws -> NSDictionary? {
        var toBeProperties: Unmanaged<CFMutableDictionary>?
        let resolveResult = IORegistryEntryCreateCFProperties(device, &toBeProperties, kCFAllocatorDefault, 0)
        
        if resolveResult != KERN_SUCCESS {
            return nil
        }
        
        if let toBeProperties = toBeProperties {
            let properties = (toBeProperties.takeUnretainedValue() as NSDictionary)
            return properties
        }
        
        return nil
    }
    
    // Get the metadata of a serial port.
    private func getSerialDeviceMeta(_ device: io_object_t) throws -> SerialPortMeta {
        guard let bsdPath = IORegistryEntryCreateCFProperty(device, "IOCalloutDevice" as CFString, kCFAllocatorDefault, 0) else {
            throw DetectorError.portPathDetectingError
        }
        
        guard let portPath = bsdPath.takeUnretainedValue() as? String else {
            throw DetectorError.portPathInvalid
        }
        
        // initialize current device tree and find its parrent device
        var parentDevice = device
        var hasUSBController = false
        var vendorID: String?
        var productID: String?
        var locationID: String?
        
        detectLoop: repeat {
            var tempParentDevice: io_object_t = 0
            let lookupResult = IORegistryEntryGetParentEntry(parentDevice, kIOServicePlane, &tempParentDevice)
            
            if (lookupResult != KERN_SUCCESS) {
                break detectLoop
            }
            
            if (parentDevice != device) {
                IOObjectRelease(parentDevice)
            }
            
            parentDevice = tempParentDevice
            
            let deviceClassName = try getDeviceClassName(parentDevice)
            if deviceClassName.contains("USB") {
                hasUSBController = true
                if let properties = try getDeviceProperties(parentDevice) {
                    if let rawVID = properties["idVendor"] {
                        vendorID = try convertNSCFNumberToHexString(rawVID)
                    }
                    if let rawPID = properties["idProduct"] {
                        productID = try convertNSCFNumberToHexString(rawPID)
                    }
                    if let rawLID = properties["locationID"] {
                        locationID = try convertNSCFNumberToHexString(rawLID)
                    }
                }
                break
            }
        } while true
        
        if parentDevice != device {
            IOObjectRelease(parentDevice)
        }
        
        var resolved = USBName(vendorName: "Unknown", productName: "Unknown")
        
        if let vendorID = vendorID {
            resolved = idsFinder.query(vendorID: vendorID, productID: productID)
        }
        
        return SerialPortMeta(
            portPath: portPath,
            hasUSBController: hasUSBController,
            vendorID: vendorID,
            vendorName: resolved.vendorName,
            productID: productID,
            productName: resolved.productName,
            locationID: locationID
        )
    }
    
    /// Discover and return all the available serial port on current system
    public func discoverSerialPorts() throws -> [SerialPortMeta] {
        var matchedDeviceMetas: [SerialPortMeta] = []
        
        let serialPortIterator = try getSerialPortIterator()
        guard serialPortIterator != 0 else {
            throw DetectorError.failedToGetSerialPortIterator
        }
        defer {
            IOObjectRelease(serialPortIterator)
        }
        
        var device: io_object_t = 0
        repeat {
            device = IOIteratorNext(serialPortIterator)
            guard device != 0 else {
                break
            }
            defer {
                IOObjectRelease(device)
            }
            
            let deviceMeta = try getSerialDeviceMeta(device)
            matchedDeviceMetas.append(deviceMeta)
        } while true
        
        return matchedDeviceMetas
    }
}
