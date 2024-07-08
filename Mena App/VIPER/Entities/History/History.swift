//
//  History.swift
//  Mena App
//
//  Created by Shoaib_iOSDeveloper on 02/07/2024.
//  Copyright © 2024 Shoaib. All rights reserved.
//

import Foundation
struct History : Codable {
    let result : [HistoryData]?

    enum CodingKeys: String, CodingKey {

        case result = "result"
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        result = try values.decodeIfPresent([HistoryData].self, forKey: .result)
    }

}

struct HistoryData : Codable {
    var amount : Double?
    var contract_address : String?
    var date : String?
    var from_address : String?
    var id : Int?
    var receive_address : String?
    var tx_hash : String?

    enum CodingKeys: String, CodingKey {

        case amount = "amount"
        case contract_address = "contract_address"
        case date = "date"
        case from_address = "from_address"
        case id = "id"
        case receive_address = "receive_address"
        case tx_hash = "tx_hash"
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        amount = try values.decodeIfPresent(Double.self, forKey: .amount)
        contract_address = try values.decodeIfPresent(String.self, forKey: .contract_address)
        date = try values.decodeIfPresent(String.self, forKey: .date)
        from_address = try values.decodeIfPresent(String.self, forKey: .from_address)
        id = try values.decodeIfPresent(Int.self, forKey: .id)
        receive_address = try values.decodeIfPresent(String.self, forKey: .receive_address)
        tx_hash = try values.decodeIfPresent(String.self, forKey: .tx_hash)
    }
    
    init(amount: Double?, contract_address: String?, date: String?, from_address: String?, id: Int?, receive_address: String?, tx_hash: String?) {
            self.amount = amount
            self.contract_address = contract_address
            self.date = date
            self.from_address = from_address
            self.id = id
            self.receive_address = receive_address
            self.tx_hash = tx_hash
        }

}
