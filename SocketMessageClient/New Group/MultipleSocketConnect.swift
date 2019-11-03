//
//  MultipleSocketConnect.swift
//  SocketMessageClient
//
//  Created by Victor on 02.11.2019.
//  Copyright © 2019 Victor. All rights reserved.
//

import Foundation
import MMLanScan

class MultipleSocketConnect {
    private var socketStreams: [MMDevice: SMTCPSocketStreams] = [:]
  
    private(set) var firstPort: Int
    private(set) var endPort: Int
    
    init(firstPort: Int,
         endPort: Int) {
        self.firstPort = firstPort
        self.endPort = endPort
    }
    
    func addDevice(_ device: MMDevice) {
        for port in firstPort ... endPort {
            let socketStream = SMTCPSocketStreams(ip: device.ipAddress, andPort: port)
            socketStream?.delegate = self
            socketStream?.connect()
            socketStream?.start()
        }
    }
}

extension MultipleSocketConnect: SMTCPSocketStreamsDelegate {
    func smtcpSocketStreams(_ socketStreams: SMTCPSocketStreams!, didReceivedMessage message: String!, atIp ip: String!, atPort port: Int) {
        
    }
}
