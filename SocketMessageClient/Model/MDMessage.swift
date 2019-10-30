//
//  MDMessage.swift
//  SocketMessageClient
//
//  Created by Victor on 28.10.2019.
//  Copyright © 2019 Victor. All rights reserved.
//

import Foundation

struct MDMessage {
    enum MessageType {
        case incoming
        case outcoming
    }
    
    let message: String
    let date: Date
    let type: MessageType
}
