//
//  MDDevice.swift
//  SocketMessageClient
//
//  Created by Victor on 31.10.2019.
//  Copyright © 2019 Victor. All rights reserved.
//

import Foundation

struct MDDevice {
    enum DeviceType {
        case notActive
        case active(port: Int)
    }
    
    let ip: String
    let type: DeviceType
    let computerName: String
    
    var port: Int? {
        switch type {
        case .active(let port):
            return port
        default:
            return nil
        }
    }
}

//MARK: -Equatable
extension MDDevice: Equatable {
    static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.ip == rhs.ip && lhs.port == rhs.port && lhs.computerName == rhs.computerName
    }
}

//MARK: -Hashable
extension MDDevice: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(ip)
        hasher.combine(port)
        hasher.combine(computerName)
    }
}
