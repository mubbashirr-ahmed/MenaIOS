//
//  BankDetail.swift
//  Mena App
//
//  Created by Shoaib_iOSDeveloper on 06/07/2024.
//  Copyright © 2024 Shoaib. All rights reserved.
//

import Foundation

struct BankDetail: JSONSerializable{
    var auth_key : String?
    var email : String?
    var type : String?
    var accountName : String?
    var sortCode : String?
    var accountNumber : String?
    var accountCountry : String?
    
    enum CodingKeys: String, CodingKey {
        
        case auth_key = "auth_key"
        case email = "email"
        case type = "type"
        case accountName = "account_name"
        case sortCode = "sort_code"
        case accountNumber = "account_number"
        case accountCountry = "account_country"
    }
}
