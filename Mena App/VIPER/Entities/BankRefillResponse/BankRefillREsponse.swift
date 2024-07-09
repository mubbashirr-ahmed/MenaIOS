//
//  BankRefillREsponse.swift
//  Mena App
//
//  Created by Shoaib_iOSDeveloper on 07/07/2024.
//  Copyright © 2024 Shoaib. All rights reserved.
//

import Foundation
struct BankRefillResponse: Codable{
    
    var result: String?
    var error: String?
    var date: Date? = nil
}
