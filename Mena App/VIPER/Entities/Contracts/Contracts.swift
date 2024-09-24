//
//  Contracts.swift
//  Mena App
//
//  Created by Shoaib_iOSDeveloper on 03/07/2024.
//  Copyright © 2024 Shoaib. All rights reserved.
//

import Foundation
struct Contracts : Codable {
    let address : String?
    let currency : String?
    let currencyName : String?
    let currencyRate : String?
    let decimalCount : Int?

    enum CodingKeys: String, CodingKey {

        case address = "address"
        case currency = "currency"
        case currencyName = "currencyName"
        case currencyRate = "currencyRate"
        case decimalCount = "decimalCount"
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        address = try values.decodeIfPresent(String.self, forKey: .address)
        currency = try values.decodeIfPresent(String.self, forKey: .currency)
        currencyName = try values.decodeIfPresent(String.self, forKey: .currencyName)
        currencyRate = try values.decodeIfPresent(String.self, forKey: .currencyRate)
        decimalCount = try values.decodeIfPresent(Int.self, forKey: .decimalCount)
    }

    init(address: String, currency: String, currencyName: String, currencyRate: String?, decimalCount: Int?) {
            self.address = address
            self.currency = currency
            self.currencyName = currencyName
            self.currencyRate = currencyRate
            self.decimalCount = decimalCount
        }
}
