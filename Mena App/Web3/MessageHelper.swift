//
//  MessageHelper.swift
//  Mena App
//
//  Created by Shoaib_iOSDeveloper on 24/06/2024.
//  Copyright © 2024 Shoaib. All rights reserved.
//

import Foundation

class MessageHelper{
    
    class func getMessage() -> String {
        let alphanumeric = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890"
        var res = ""
        for _ in 0..<8 {
            let randIndex = Int(arc4random_uniform(UInt32(alphanumeric.count)))
            let char = alphanumeric[alphanumeric.index(alphanumeric.startIndex, offsetBy: randIndex)]
            res.append(char)
        }
        let date = getDateTimeFormatted()
        return "\(res),\(date),connecting to Trawda"
    }
    
    class func getDateTimeFormatted() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.timeZone = TimeZone(abbreviation: "UTC")
        let nowInUtc = Date()
        return formatter.string(from: nowInUtc)
    }
    
}
