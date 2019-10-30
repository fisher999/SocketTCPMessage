//
//  TaskCell.swift
//  SocketMessageClient
//
//  Created by Victor on 30.10.2019.
//  Copyright © 2019 Victor. All rights reserved.
//

import UIKit

class TaskCell: UITableViewCell {
    static var id: String {
        return "TaskCell"
    }
    
    @IBOutlet fileprivate weak var label: UILabel!

    var model: String? {
        didSet {
            label.text = model
        }
    }
}
