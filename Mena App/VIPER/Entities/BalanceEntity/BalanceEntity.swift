//
//  BalanceEntity.swift
//  Mena App
//
//  Created by Shoaib_iOSDeveloper on 14/07/2024.
//  Copyright © 2024 Shoaib. All rights reserved.
//

import Foundation

struct BalanceEntity: Codable{
    
    var id : Int?
    var name: String?
    var symbol: String?
    var balance: Double?
    var contratAddress: String?
    var decimalCount: Int?
    var conversionRate: Double?
    
}
