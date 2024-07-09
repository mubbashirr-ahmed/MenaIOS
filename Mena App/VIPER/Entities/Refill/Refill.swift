//
//  Refill.swift
//  Mena App
//
//  Created by Shoaib_iOSDeveloper on 06/07/2024.
//  Copyright © 2024 Shoaib. All rights reserved.
//

import Foundation

struct RefillRequest: JSONSerializable{
    var auth_key : String?
    var email : String?
    var type : String?
    var coin : String?
    var amount : String?
    var country : String?
    var currencyType : String?
    
    enum CodingKeys: String, CodingKey {
        
        case auth_key = "auth_key"
        case email = "email"
        case type = "type"
        case coin = "coin"
        case amount = "amount"
        case country = "country"
        case currencyType = "currency-type"
        
    }
}
