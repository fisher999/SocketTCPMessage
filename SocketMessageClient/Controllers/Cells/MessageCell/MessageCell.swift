//
//  TableViewCell.swift
//  SocketMessageClient
//
//  Created by Victor on 28.10.2019.
//  Copyright © 2019 Victor. All rights reserved.
//

import UIKit

class MessageCell: UITableViewCell {
    static var id: String {
        return "MessageCell"
    }
    
    @IBOutlet weak fileprivate var messageLabel: UILabel!
    @IBOutlet weak fileprivate var dateLabel: UILabel!
    
    var model: MDMessage? {
        didSet {
            setupModel(model)
        }
    }
    
    private func setupModel(_ model: MDMessage?) {
        guard let model = model else {return}
        self.messageLabel.text = model.message
        switch model.type {
        case .incoming:
            self.messageLabel.textAlignment = .right
            self.dateLabel.textAlignment = .right
        case .outcoming:
            self.messageLabel.textAlignment = .left
            self.dateLabel.textAlignment = .left
        }
        self.dateLabel.text = model.date.getTimeString(withFormat: "hh:mm:ss dd.MM.YY")
    }
}
