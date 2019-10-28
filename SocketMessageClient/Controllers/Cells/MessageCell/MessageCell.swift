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
    
    var model: String? {
        didSet {
            self.messageLabel.text = model
        }
    }
}
