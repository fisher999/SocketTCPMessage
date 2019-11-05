//
//  DeviceCell.swift
//  SocketMessageClient
//
//  Created by Victor on 30.10.2019.
//  Copyright © 2019 Victor. All rights reserved.
//

import UIKit


class DeviceCell: UITableViewCell {
    static var id: String {
        return "DeviceCell"
    }
        
    @IBOutlet fileprivate weak var deviceLabel: UILabel!
    
    
    var model: MDDevice? {
        didSet {
            setup(model: model)
        }
    }
    
    private func setup(model: MDDevice?) {
        guard let model = model else {return}
        switch model.type {
        case .notActive:
            self.deviceLabel.text = "\(model.ip):\(model.computerName)"
        case .active(let port):
            self.deviceLabel.text = "\(model.ip):\(port):\(model.computerName)"
        }
    }
}
