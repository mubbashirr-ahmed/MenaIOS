//
//  CountryCurrency.swift
//  Mena App
//
//  Created by Shoaib_iOSDeveloper on 06/07/2024.
//  Copyright © 2024 Shoaib. All rights reserved.
//

import Foundation

struct CountryCurrency : Codable {
    let countries : [Countries]?
    let currencies : [Currencies]?

    enum CodingKeys: String, CodingKey {

        case countries = "countries"
        case currencies = "currencies"
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        countries = try values.decodeIfPresent([Countries].self, forKey: .countries)
        currencies = try values.decodeIfPresent([Currencies].self, forKey: .currencies)
    }
    

}

struct Currencies : Codable {
    let fiatCurrency : String?

    enum CodingKeys: String, CodingKey {

        case fiatCurrency = "fiatCurrency"
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        fiatCurrency = try values.decodeIfPresent(String.self, forKey: .fiatCurrency)
    }
    init(fiatCurrency: String){
        self.fiatCurrency = fiatCurrency
    }

}

struct Countries : Codable {
    let country : String?

    enum CodingKeys: String, CodingKey {

        case country = "country"
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        country = try values.decodeIfPresent(String.self, forKey: .country)
    }

    init(country: String){
        self.country = country
    }
}
