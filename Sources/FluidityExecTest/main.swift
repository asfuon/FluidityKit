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

//func main() throws {
//    let ins = try SerialPortDetector()
//    
//    let result = try ins.discoverSerialPorts()
//    
//    var matchedMeta: SerialPortMeta?
//    
//    for el in result {
//        if (el.portPath == "/dev/cu.wchusbserial1140") {
//            matchedMeta = el
//            break
//        }
//    }
//    
//    guard let matchedMeta = matchedMeta else {
//        return
//    }
//    
//    let portIns = try SerialPort(from: matchedMeta)
//    
//    try portIns.openPort(enableRX: true, enableTX: false)
//    
//    let queue = DispatchQueue(label: "sh.aimless.serial.reading")
//    let timer = DispatchSource.makeTimerSource(queue: queue)
//    timer.schedule(deadline: .now(), repeating: 0.2)
//    timer.setEventHandler {
//        do {
//            let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: 1024)
//            defer {
//                buffer.deallocate()
//            }
//            let data = try portIns.readBytes(into: buffer, length: 1024)
////            if let string = String(data: data, encoding: .utf8) {
////                print("Received: \(string)")
////            } else {
////                // Print raw bytes if not UTF-8
////                print("Received bytes: \(Array(data))")
////            }
//            print(data)
//        } catch {
//            print("Unexpected")
//        }
//    }
//    
//    timer.resume()
//    
//    RunLoop.current.run()
//    
//    let data = try portIns.readData(length: 20)
//    
//    if let p = String(data: data, encoding: String.Encoding.utf8) {
//        print(p)
//    }
//
//    portIns.closePort()
//}
//
//try main()
//
//import Foundation
//import IOKit
//import IOKit.serial
//
//class SerialPortManager {
//    private var serialPort: Int32 = -1
//    
//    func openSerialPort(path: String, baudRate: speed_t = speed_t(B9600)) -> Bool {
//        // Open the serial port
//        serialPort = Darwin.open(path, O_RDWR | O_NOCTTY | O_NONBLOCK)
//        
//        if serialPort == -1 {
//            print("Error opening serial port")
//            return false
//        }
//        
//        var options = termios()
//        
//        // Get the current options
//        if tcgetattr(serialPort, &options) == -1 {
//            print("Error getting port attributes")
//            closeSerialPort()
//            return false
//        }
//        
//        // Set input and output baud rates
//        cfmakeraw(&options)
//        cfsetispeed(&options, baudRate)
//        cfsetospeed(&options, baudRate)
//        
//        // Configure the port settings
//        options.c_cflag |= tcflag_t(CS8 | CLOCAL | CREAD)  // 8 bits, local mode, enable receiver
//        options.c_cflag &= ~tcflag_t(PARENB | PARODD)      // No parity
//        options.c_cflag &= ~tcflag_t(CSTOPB)                 // 1 stop bit
//        options.c_cflag &= ~tcflag_t(CRTSCTS)                // No hardware flow control
//        
//        // Set input options - disable break signal, CR-to-NL translation,
//        // parity check, strip high bit, and software flow control
//        options.c_iflag &= ~tcflag_t(IGNBRK | BRKINT | ICRNL | INLCR | PARMRK | INPCK | ISTRIP | IXON)
//        
//        // Set output options - disable post-processing
//        options.c_oflag &= ~tcflag_t(OCRNL | ONLCR | ONLRET | ONOCR | OFILL | OPOST)
//        
//        // Set local options - disable canonical mode, echo, erasure, and signals
//        options.c_lflag &= ~tcflag_t(ECHO | ECHONL | ICANON | IEXTEN | ISIG)
//        
////        // Set read timeout parameters
////        options.c_cc[VMIN] = 0   // Minimum number of characters to read
////        options.c_cc[VTIME] = 10 // Read timeout in tenths of a second
////        
//        // Apply the new settings
//        if tcsetattr(serialPort, TCSANOW, &options) == -1 {
//            print("Error setting port attributes")
//            closeSerialPort()
//            return false
//        }
//        
//        // Clear the port
//        tcflush(serialPort, TCIOFLUSH)
//        
//        return true
//    }
//    
//    func closeSerialPort() {
//        if serialPort != -1 {
//            Darwin.close(serialPort)
//            serialPort = -1
//        }
//    }
//    
//    func writeData(_ data: Data) -> Int {
//        return data.withUnsafeBytes { buffer in
//            Darwin.write(serialPort, buffer.baseAddress, buffer.count)
//        }
//    }
//    
//    enum SerialError: Error {
//        case readError(String)
//        case invalidData
//    }
//    
//    func readData(maxLength: Int = 1024) throws -> Data {
//        var buffer = [UInt8](repeating: 0, count: maxLength)
//        let bytesRead = Darwin.read(serialPort, &buffer, maxLength)
//        
//        if bytesRead < 0 {
//            throw SerialError.readError("Failed to read from serial port: \(String(cString: strerror(errno)))")
//        }
//        
//        if bytesRead == 0 {
//            throw SerialError.readError("No data available")
//        }
//        
//        return Data(buffer[0..<bytesRead])
//    }
//    
//    func waitAndPrintData(timeout: TimeInterval = 0.1) {
//        let queue = DispatchQueue(label: "com.serial.reading")
//        let timer = DispatchSource.makeTimerSource(queue: queue)
//        
//        timer.schedule(deadline: .now(), repeating: timeout)
//        timer.setEventHandler {
//            do {
//                let data = try self.readData()
//                if let string = String(data: data, encoding: .utf8) {
//                    print("Received: \(string)")
//                } else {
//                    // Print raw bytes if not UTF-8
//                    print("Received bytes: \(Array(data))")
//                }
//            } catch SerialError.readError(let message) {
//                if message != "No data available" {  // Don't print timeout messages
//                    print("Error: \(message)")
//                }
//            } catch {
//                print("Unexpected error: \(error)")
//            }
//        }
//        
//        timer.resume()
//        
//        // Keep the main thread running
//        print("Waiting for data... Press Ctrl+C to stop")
//        RunLoop.current.run()
//    }
//}
//
//let manager = SerialPortManager()
//if manager.openSerialPort(path: "/dev/cu.wchusbserial1140") {
//    manager.waitAndPrintData()
//}

// Define the serial device path
let serialPortPath = "/dev/cu.wchusbserial1140"

// Open the serial port
let fileDescriptor = open(serialPortPath, O_RDWR | O_NOCTTY | O_NONBLOCK)

if fileDescriptor == -1 {
    perror("Error: Unable to open serial port")
    exit(EXIT_FAILURE)
}

// Configure the serial port
var options = termios()
if tcgetattr(fileDescriptor, &options) != 0 {
    perror("Error: Unable to get terminal attributes")
    close(fileDescriptor)
    exit(EXIT_FAILURE)
}

cfsetispeed(&options, speed_t(B115200)) // Set input baud rate
cfsetospeed(&options, speed_t(B115200)) // Set output baud rate
options.c_cflag |= tcflag_t(CLOCAL | CREAD) // Enable receiver and set local mode
options.c_cflag &= ~tcflag_t(CSIZE) // Clear size bits
options.c_cflag |= tcflag_t(CS8) // Set 8 data bits
options.c_cflag &= ~tcflag_t(PARENB) // Disable parity
options.c_cflag &= ~tcflag_t(CSTOPB) // Use one stop bit
options.c_cflag &= ~tcflag_t(CRTSCTS) // Disable hardware flow control

if tcsetattr(fileDescriptor, TCSANOW, &options) != 0 {
    perror("Error: Unable to set terminal attributes")
    close(fileDescriptor)
    exit(EXIT_FAILURE)
}

print("Listening on \(serialPortPath) at 115200 baud...")

// Create a buffer for incoming data
let bufferSize = 256
var buffer = [UInt8](repeating: 0, count: bufferSize)
var receivedData = Data()

while true {
    let bytesRead = read(fileDescriptor, &buffer, bufferSize)
    if bytesRead > 0 {
        // Append raw bytes to the buffer
        receivedData.append(contentsOf: buffer[0..<bytesRead])

        // Debug: Print raw data in hexadecimal
        let hexString = receivedData.map { String(format: "%02X", $0) }.joined(separator: " ")
        print("Raw Data (Hex): \(hexString)")

        // Check for a newline character
        if let lineTerminatorRange = receivedData.range(of: Data([10])) { // Newline character (\n)
            let line = receivedData.subdata(in: 0..<lineTerminatorRange.startIndex)
            receivedData.removeSubrange(0...lineTerminatorRange.endIndex - 1)
            
            // Decode and print the line
            if let decodedString = String(data: line, encoding: .utf8) {
                print("Decoded: \(decodedString)")
            } else {
                print("Error: Unable to decode line")
            }
        }
    }
    
    usleep(100000) // Sleep for 100ms to reduce CPU usage
}

// Close the file descriptor (this line will not be reached in the current infinite loop)
close(fileDescriptor)
