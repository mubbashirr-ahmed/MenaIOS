//
//  RefillData+CoreData.swift
//  Mena App
//
//  Created by Shoaib_iOSDeveloper on 07/07/2024.
//  Copyright © 2024 Shoaib. All rights reserved.
//

import Foundation

extension RefillCoreData{
    
    func toRefillResponse() -> BankRefillResponse {
        return BankRefillResponse(result: result, error: nil, date: date)
    }
    
}
