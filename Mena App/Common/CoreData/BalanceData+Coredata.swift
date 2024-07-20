//
//  BalanceData+Coredata.swift
//  Mena App
//
//  Created by Shoaib_iOSDeveloper on 16/07/2024.
//  Copyright © 2024 Shoaib. All rights reserved.
//

import Foundation
extension BalanceCoreData{
    func toBalance()-> BalanceEntity{
        return BalanceEntity(id: Int(16), name: name, symbol: symbol, balance: Double(balance ?? "0.0"), contratAddress: contratAddress, decimalCount: Int(decimalCount) , conversionRate: Double(conversionRate))
    }
}
