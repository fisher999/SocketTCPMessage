//
//  SocketStream.swift
//  SocketMessageClient
//
//  Created by Victor on 25.10.2019.
//  Copyright © 2019 Victor. All rights reserved.
//

import Foundation

protocol SocketStreamDelegate: class {
    func socketStream(_ socketStream: SocketStream, receivedMessage message: String)
}

class SocketStream: NSObject {
    private var inputStream: InputStream?
    private var outputStream: OutputStream?
    weak var delegate: SocketStreamDelegate?
    var maxReadLength: Int = 4096
    
    private let _host: String
    var host: String {
        return _host
    }
    
    private let _port: Int
    var port: Int {
        return _port
    }
    
    init(withHost host: String,
         port: Int) {
        self._host = host
        self._port = port
        super.init()
    }
    
    deinit {
        self.disconnect()
    }
    
    func connect() {
        var readStream: Unmanaged<CFReadStream>?
        var writeStream: Unmanaged<CFWriteStream>?
        CFStreamCreatePairWithSocketToHost(kCFAllocatorDefault,
                                           _host as CFString,
                                           UInt32(_port),
                                           &readStream,
                                           &writeStream)
        inputStream = readStream!.takeRetainedValue()
        outputStream = writeStream!.takeRetainedValue()
        inputStream?.delegate = self
        inputStream?.schedule(in: .current, forMode: .common)
        outputStream?.schedule(in: .current, forMode: .common)
        inputStream?.open()
        outputStream?.open()
    }

    func disconnect() {
        inputStream?.close()
        outputStream?.close()
    }
}

//MARK: -Write
extension SocketStream {
    func sendMessage(_ message: String) {
        let data = message.data(using: .utf8)!
        _ = data.withUnsafeBytes {
            guard let pointer = $0.baseAddress?.assumingMemoryBound(to: UInt8.self) else {
                print("cant get message pointer")
                return
            }
            outputStream?.write(pointer, maxLength: data.count)
        }
    }
}

//MARK: -Read
extension SocketStream: StreamDelegate {
    //MARK: Stream delegate
    func stream(_ aStream: Stream,
                handle eventCode: Stream.Event) {
        switch aStream {
        case is InputStream:
            let stream = aStream as! InputStream
            proposeInputStream(stream, withEvent: eventCode)
        default:
            break
        }
    }
    
    //MARK: Helping methods
    private func proposeInputStream(_ inputStream: InputStream,
                                    withEvent event: Stream.Event) {
        switch event {
        case .hasBytesAvailable:
            readAvailableBytes(stream: inputStream)
        default:
            return
        }
    }
    
    private func readAvailableBytes(stream: InputStream) {
        let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: maxReadLength)
        while stream.hasBytesAvailable {
            guard let numberOfBytesRead = inputStream?.read(buffer, maxLength: maxReadLength) else {return}
            if numberOfBytesRead < 0, let error = stream.streamError {
                print(error)
                break
            }
            if let message = proccessedMessageString(buffer: buffer, length: numberOfBytesRead) {
                delegate?.socketStream(self, receivedMessage: message)
            }
        }
    }
    
    private func proccessedMessageString(buffer: UnsafeMutablePointer<UInt8>,
                                         length: Int) -> String? {
        return String(bytesNoCopy: buffer,
                      length: length,
                      encoding: .utf8,
                      freeWhenDone: true)
    }
}
