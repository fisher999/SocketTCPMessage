//
//  Date+Format.swift
//  SocketMessageClient
//
//  Created by Victor on 28.10.2019.
//  Copyright © 2019 Victor. All rights reserved.
//

import Foundation

extension Date {
    func getTimeString(withFormat format: String) -> String {
        let df = DateFormatter()
        df.dateFormat = format
        
        return df.string(from: self)
    }
}
