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
    public var rxBaudRate: BaudRate
    
    /// The baud rate used to communicate from host to remote (send)
    public var txBaudRate: BaudRate
    
    /// The parity bit setting used to communicate between TX and RX
    public var parityBit: ParityBit
    
    /// Whether to send two stop bits in communication
    public var useTwoStopBits: Bool
    
    /// The data bits size used to communication
    public var dataBitsSize: DataBitsSize
}

/// Centered Serial Port instance for device setting and data transmission.
public class SerialPort {
    let metadata: SerialPortMeta
    var options: SerialPortOptions
    var port: Int32?
    
    public enum SerialPortError: Error {
        case invalidSerialPortPath
        case invalidTransmissionDirection
        case failedToOpenSerialPort
        case portIsClosed
        case deviceDisconnected
        case bufferReadingError
        case invalidReadBytes
    }
    
    /// Create a Serial Port instance from given metadatas.
    public init(from: SerialPortMeta) throws {
        self.metadata = from
        
        // create port options by default
        // @todo: move the default options to another place
        options = SerialPortOptions(
            rxBaudRate: .baud115200,
            txBaudRate: .baud115200,
            parityBit: .unset,
            useTwoStopBits: false,
            dataBitsSize: .bits8
        )
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
        
        try loadOptions()
    }
    
    /// Close serial port connection.
    public func closePort() {
        if let port = port {
            close(port)
        }
        port = nil
    }
    
    /// Update port settings based on current context options.
    private func loadOptions() throws {
        var payload = termios()
        if let port = port {
            tcgetattr(port, &payload)
            
            // set baud rates
            cfsetispeed(&payload, options.rxBaudRate.value)
            cfsetospeed(&payload, options.txBaudRate.value)
            
            // set parity bit
            payload.c_cflag |= options.parityBit.value
            
            // set two stop bits usage
            if (options.useTwoStopBits) {
                payload.c_cflag |= tcflag_t(CSTOPB)
            } else {
                payload.c_cflag &= ~tcflag_t(CSTOPB)
            }
            
            // set data bits size
            payload.c_cflag &= ~tcflag_t(CSIZE)
            payload.c_cflag |= options.dataBitsSize.value
            
            // @todo: make a option
            // disable hardware flow control
            payload.c_cflag &= ~tcflag_t(CRTSCTS)
            
            // disable break signal, CR-to-NL translation,
            // parity check, strip high bit, and software flow control
            payload.c_cflag &= ~tcflag_t(IGNBRK | BRKINT | ICRNL | INLCR | PARMRK | INPCK | ISTRIP | IXON)
            
            // disable post-processing
            payload.c_oflag &= ~tcflag_t(OCRNL | ONLCR | ONLRET | ONOCR | OFILL | OPOST)
            
            // disable canonical mode, echo, erasure, and signals
            payload.c_lflag &= ~tcflag_t(ECHO | ECHONL | ICANON | IEXTEN | ISIG)
            
            // apply changes
            tcsetattr(port, TCSANOW, &payload)
        } else {
            throw SerialPortError.portIsClosed
        }
    }
    
    /// Set the whole options to resolve and send serial port data.
    public func setOptions(_ payload: SerialPortOptions) throws {
        self.options = payload
        
        // apply changes
        if port != nil {
            try loadOptions()
        }
    }
    
    /// Set partial options to resolve and send serial port data.
    public func setOptions(
        rxBaudRate: BaudRate? = nil,
        txBaudRate: BaudRate? = nil,
        parityBit: ParityBit? = nil,
        useTwoStopBits: Bool? = nil,
        dataBitsSize: DataBitsSize? = nil
    ) throws {
        if let rxBaudRate = rxBaudRate {
            self.options.rxBaudRate = rxBaudRate
        }
        if let txBaudRate = txBaudRate {
            self.options.txBaudRate = txBaudRate
        }
        if let parityBit = parityBit {
            self.options.parityBit = parityBit
        }
        if let useTwoStopBits = useTwoStopBits {
            self.options.useTwoStopBits = useTwoStopBits
        }
        if let dataBitsSize = dataBitsSize {
            self.options.dataBitsSize = dataBitsSize
        }
        
        // apply changes
        if port != nil {
            try loadOptions()
        }
    }
}

/// The receiver logic of Serial Port instance.
extension SerialPort {
    /// Function to check if port opened correctly, throws if no.
    private func ensurePortStatus() throws {
        guard let port = port else {
            throw SerialPortError.portIsClosed
        }

        var fileStat: stat = stat()
        fstat(port, &fileStat)
        
        print(fileStat.st_nlink)
        
        guard fileStat.st_nlink == 1 else {
            throw SerialPortError.deviceDisconnected
        }
    }
    
    /// Read a single byte from serial port.
    public func readSingleByte(into buffer: UnsafeMutablePointer<UInt8>) throws -> Int {
        let target = try readBytes(into: buffer, length: 1)
        return target
    }
    
    /// Read bytes from serial port.
    public func readBytes(into buffer: UnsafeMutablePointer<UInt8>, length len: Int) throws -> Int {
        try ensurePortStatus()
        
        guard let port = port else {
            throw SerialPortError.portIsClosed
        }
        
        let target = read(port, buffer, len)
        return target
    }
    
    /// Read to Data type.
    public func readData(length len: Int) throws -> Data {
        let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: len)
        defer {
            buffer.deallocate()
        }
        
        let readCount = try readBytes(into: buffer, length: len)
        
        guard readCount > 0 else {
            throw SerialPortError.invalidReadBytes
        }
        
        return Data(bytes: buffer, count: readCount)
    }
}
