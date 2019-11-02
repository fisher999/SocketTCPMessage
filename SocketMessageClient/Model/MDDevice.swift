//
//  MDDevice.swift
//  SocketMessageClient
//
//  Created by Victor on 31.10.2019.
//  Copyright © 2019 Victor. All rights reserved.
//

import Foundation

struct MDDevice {
    let ip: String
    let port: String
    let computerName: String
}

//MARK: -Equatable
extension MDDevice: Equatable {
    static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.ip == rhs.ip && lhs.port == rhs.port && lhs.computerName == rhs.computerName
    }
}
