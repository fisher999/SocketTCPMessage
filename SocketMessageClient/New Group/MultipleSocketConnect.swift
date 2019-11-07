//
//  MultipleSocketConnect.swift
//  SocketMessageClient
//
//  Created by Victor on 02.11.2019.
//  Copyright © 2019 Victor. All rights reserved.
//

import Foundation
import MMLanScan

protocol MultipleSocketConnectDelegate: class {
    func multipleSocketConnect(_ multipleSocketConnect: MultipleSocketConnect, didAppendNewActiveDevice device: MDDevice)
}

class MultipleSocketConnect {
    var socketDevices: [MDDevice: SMTCPSocketStreams] = [:]
    private var allDevices: [LANDevice] = []
    private var allStreams: [SMTCPSocketStreams] = []
    
    weak var delegate: MultipleSocketConnectDelegate?
    
    private(set) var firstPort: Int
    private(set) var endPort: Int
    
    init(firstPort: Int,
         endPort: Int) {
        self.firstPort = firstPort
        self.endPort = endPort
    }
    
    func connectTo(_ device: LANDevice) {
        self.allDevices.append(device)
        for port in firstPort ... endPort {
            let socketStream = SMTCPSocketStreams(ip: device.ipAddress, andPort: port)
            socketStream?.delegate = self
            socketStream?.connect()
            if let stream = socketStream {
                self.allStreams.append(stream)
            }
            socketStream?.writeMessage("Do you understand me?", dispatchAfter: 0)
        }
    }
    
    func disconnect() {
        for stream in self.allStreams {
            stream.close()
        }
    }
    
    deinit {
        disconnect()
        self.allStreams = []
    }
}

//MARK: -SMTCPSocketStreamsDelegate
extension MultipleSocketConnect: SMTCPSocketStreamsDelegate {
    func smtcpSocketStreams(_ socketStreams: SMTCPSocketStreams!, didReceivedMessage message: String!, atIp ip: String!, atPort port: Int) {
        self.proposeMessageFrom(socketStreams, message, atIp: ip, atPort: port)
    }
    
    private func proposeMessageFrom(_ socketStreams: SMTCPSocketStreams, _ message: String!, atIp ip: String!, atPort port: Int) {
        print("message: \(String(describing: message))")
        for device in self.allDevices where device.ipAddress == ip {
            let newDevice = MDDevice(ip: ip, type: .active(port: port), computerName: device.hostname)
            self.socketDevices[newDevice] = socketStreams
            self.delegate?.multipleSocketConnect(self, didAppendNewActiveDevice: newDevice)
        }
    }
}
