//
//  ContractData+CoreData.swift
//  Mena App
//
//  Created by Shoaib_iOSDeveloper on 04/07/2024.
//  Copyright © 2024 Shoaib. All rights reserved.
//

import Foundation
extension ContractData{
    func toContracts() -> Contracts {
        return Contracts(
            address: self.address ?? "",
            currency: self.currency ?? "",
            currencyName: self.currencyName ?? "",
            currencyRate: String(self.currencyRate),
            decimalCount: Int(self.decimalCount)
        )
    }
}
