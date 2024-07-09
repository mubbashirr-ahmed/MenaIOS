//
//  HistoryData+CoreData.swift
//  Mena App
//
//  Created by Shoaib_iOSDeveloper on 03/07/2024.
//  Copyright © 2024 Shoaib. All rights reserved.
//

import Foundation
import CoreData

extension HistoryCoreData {
    func toHistoryData() -> HistoryData {
        return HistoryData(
            amount: self.amount,
            contract_address: self.contract_address,
            date: self.date,
            from_address: self.from_address,
            id: Int(self.id),
            receive_address: self.receive_address,
            tx_hash: self.tx_hash
        )
    }
}
