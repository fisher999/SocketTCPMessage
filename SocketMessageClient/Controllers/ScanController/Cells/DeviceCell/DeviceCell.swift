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
        self.deviceLabel.text = "\(model.ip):\(model.port):\(model.computerName)"
    }
}
