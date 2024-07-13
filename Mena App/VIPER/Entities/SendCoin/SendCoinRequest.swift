//
//  SendCoinRequest.swift
//  Mena App
//
//  Created by Shoaib_iOSDeveloper on 11/07/2024.
//  Copyright © 2024 Shoaib. All rights reserved.
//

import Foundation

struct SendCoinRequest: Codable{
    let data : Transactions
}
struct Transactions: Codable{
    let transactions : [String]
}
