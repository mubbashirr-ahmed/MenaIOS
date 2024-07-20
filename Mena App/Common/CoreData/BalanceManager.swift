//
//  BalanceManager.swift
//  Mena App
//
//  Created by Shoaib_iOSDeveloper on 15/07/2024.
//  Copyright © 2024 Shoaib. All rights reserved.
//

import Foundation
import CoreData
import UIKit

class BalanceManager {
    let context: NSManagedObjectContext
    
    init() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        context = appDelegate.context
    }
    
    // Create
    func createBalances(_ balances: [BalanceEntity]) -> Bool {
        for balance in balances {
            let newBalance = BalanceCoreData(context: context)
            newBalance.id = Int16(balance.id ?? 0)
            newBalance.name = balance.name ?? ""
            newBalance.symbol = balance.symbol ?? ""
            newBalance.balance = String(balance.balance ?? 0.0)
            newBalance.contratAddress = balance.contratAddress ?? ""
            newBalance.decimalCount = Int16(balance.decimalCount ?? 0)
            newBalance.conversionRate = Int16(balance.conversionRate ?? 0.0)
        }
        
        do {
            try context.save()
            return true
        } catch {
            print("Error creating balances: \(error)")
            return false
        }
    }
    
    // Read
    func fetchBalances() -> [BalanceEntity]? {
        let fetchRequest = NSFetchRequest<BalanceCoreData>(entityName: "BalanceCoreData")
        
        do {
            let balances = try context.fetch(fetchRequest)
            let balanceList = balances.map { $0.toBalance()}
            return balanceList
        } catch {
            print("Error fetching balances: \(error)")
            return nil
        }
    }
    
    
    // Delete
    func deleteBalance(_ balance: BalanceEntity) -> Bool {
        let fetchRequest: NSFetchRequest<BalanceCoreData> = BalanceCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %d", balance.id ?? 0)
        
        do {
            let result = try context.fetch(fetchRequest)
            if let existingBalance = result.first {
                context.delete(existingBalance)
                try context.save()
                return true
            } else {
                print("Balance not found")
                return false
            }
        } catch {
            print("Error deleting balance: \(error)")
            return false
        }
    }
    
    // Delete All
    func deleteAllBalances() -> Bool {
        let fetchRequest = NSFetchRequest<BalanceCoreData>(entityName: "Balance")
        
        do {
            let balances = try context.fetch(fetchRequest)
            for balance in balances {
                context.delete(balance)
            }
            try context.save()
            return true
        } catch {
            print("Error deleting all balances: \(error)")
            return false
        }
    }
    
}
