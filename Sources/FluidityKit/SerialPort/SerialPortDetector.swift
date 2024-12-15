//
//  SerialPortDetector.swift
//  FluidityKit
//
//  Created by Amano Fuon on 2024/12/15.
//

import Foundation
import IOKit
import IOKit.serial

/// Detect the available serial ports on the current host (macOS only).
public class SerialPortDetector {
    /// Custom Errors of the detector
    public enum DetectorError: Error {
        case serviceMatchingError
        case portPathDetectingError
        case portPathInvalid
        case deviceClassNameInvalid
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
        var vendorID: Int?
        var vendorName: String?
        var productID: Int?
        var productName: String?
        var serialNumber: String?
        var locationID: Int?
        
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
                    vendorID = properties["idVendor"] as? Int
                    productID = properties["idProduct"] as? Int
//                    vendorName = properties["USB Vendor Name"] as? String
//                    productName = properties["USB Product Name"] as? String
//                    serialNumber = properties["USB Serial Number"] as? String
                    locationID = properties["locationID"] as? Int
                }
                break
            }
        } while true
        
        if parentDevice != device {
            IOObjectRelease(parentDevice)
        }
        
        // @todo, lookup vendorName and productName from public USB vendor database
        
        return SerialPortMeta(
            portPath: portPath,
            hasUSBController: hasUSBController,
            vendorID: vendorID,
            vendorName: vendorName,
            productID: productID,
            productName: productName,
            serialNumber: serialNumber,
            locationID: locationID
        )
    }
}
