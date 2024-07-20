//
//  TrransactionResponse.swift
//  Mena App
//
//  Created by Shoaib_iOSDeveloper on 16/07/2024.
//  Copyright © 2024 Shoaib. All rights reserved.
//

import Foundation
struct TrransactionResponse : Codable {
    let success : String?
    let error : String?

    enum CodingKeys: String, CodingKey {

        case success = "success"
        case error = "error"
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        success = try values.decodeIfPresent(String.self, forKey: .success)
        error = try values.decodeIfPresent(String.self, forKey: .error)
    }

}
