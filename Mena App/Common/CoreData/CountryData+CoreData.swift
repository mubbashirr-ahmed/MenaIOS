//
//  CountryData+CoreData.swift
//  Mena App
//
//  Created by Shoaib_iOSDeveloper on 06/07/2024.
//  Copyright © 2024 Shoaib. All rights reserved.
//

import Foundation
extension CountryCoreData{
    func toCountry() -> Countries {
        return Countries(
            country: self.country ?? ""
        )
    }
}
