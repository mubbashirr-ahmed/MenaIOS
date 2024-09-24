//
//  TransactionManager.swift
//  Mena App
//
//  Created by Shoaib_iOSDeveloper on 03/07/2024.
//  Copyright © 2024 Shoaib. All rights reserved.
//

import Foundation
import CoreData
import UIKit



class TransactionManager {
    let context: NSManagedObjectContext
      
      init() {
          let appDelegate = UIApplication.shared.delegate as! AppDelegate
          context = appDelegate.context
      }
    
    // Create
//    func createTransactions(_ transactions: [HistoryData]) -> Bool {
//        for transaction in transactions {
//            let newTransaction = HistoryCoreData(context: context)
//            newTransaction.amount = transaction.amount ?? 0.0
//            newTransaction.contract_address = transaction.contract_address ?? ""
//            newTransaction.date = transaction.date ?? ""
//            newTransaction.from_address = transaction.from_address ?? ""
//            newTransaction.id = Int64(transaction.id ?? 0)
//            newTransaction.receive_address = transaction.receive_address ?? ""
//            newTransaction.tx_hash = transaction.tx_hash
//        }
//        
//        do {
//            try context.save()
//            return true
//        } catch {
//            print("Error creating transactions: \(error)")
//            return false
//        }
//    }
    
    func createTransactions(_ transactions: [HistoryData]) -> Bool {
        // Fetch existing transactions and delete them
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "HistoryCoreData")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)

        do {
            // Execute delete request to remove all existing transactions
            try context.execute(deleteRequest)
            
            // Add new transactions after deleting the old ones
            for transaction in transactions {
                let newTransaction = HistoryCoreData(context: context)
                newTransaction.amount = transaction.amount ?? 0.0
                newTransaction.contract_address = transaction.contract_address ?? ""
                newTransaction.date = transaction.date ?? ""
                newTransaction.from_address = transaction.from_address ?? ""
                newTransaction.id = Int64(transaction.id ?? 0)
                newTransaction.receive_address = transaction.receive_address ?? ""
                newTransaction.tx_hash = transaction.tx_hash
            }
            
            // Save the context after replacing the transactions
            try context.save()
            return true
        } catch {
            print("Error replacing transactions: \(error)")
            return false
        }
    }

    // Read
    func fetchTransactions() -> [HistoryData]? {
        let fetchRequest = NSFetchRequest<HistoryCoreData>(entityName: "HistoryCoreData")
        
        do {
            let transactions = try context.fetch(fetchRequest)
            let historyData = transactions.map { $0.toHistoryData() }
            return historyData
        } catch {
            print("Error fetching transactions: \(error)")
            return nil
        }
    }
    
    // Update
//    func updateTransaction(_ transaction: HistoryData) -> Bool {
//        let fetchRequest: NSFetchRequest<HistoryData> = HistoryData.fetchRequest()
//        fetchRequest.predicate = NSPredicate(format: "id == %@", transaction.id!)
//        
//        do {
//            let result = try context.fetch(fetchRequest)
//            if let existingTransaction = result.first {
//                existingTransaction.amount = transaction.amount
//                existingTransaction.contract_address = transaction.contract_address
//                existingTransaction.date = transaction.date
//                existingTransaction.from_address = transaction.from_address
//                existingTransaction.receive_address = transaction.receive_address
//                existingTransaction.tx_hash = transaction.tx_hash
//                
//                try context.save()
//                return true
//            } else {
//                print("Transaction not found")
//                return false
//            }
//        } catch {
//            print("Error updating transaction: \(error)")
//            return false
//        }
//    }
    
    // Delete
//    func deleteTransaction(_ transaction: HistoryData) -> Bool {
//        let fetchRequest: NSFetchRequest<HistoryData> = HistoryData.fetchRequest()
//        fetchRequest.predicate = NSPredicate(format: "id == %@", transaction.id!)
//        
//        do {
//            let result = try context.fetch(fetchRequest)
//            if let existingTransaction = result.first {
//                context.delete(existingTransaction)
//                try context.save()
//                return true
//            } else {
//                print("Transaction not found")
//                return false
//            }
//        } catch {
//            print("Error deleting transaction: \(error)")
//            return false
//        }
//    }
    
    // Delete All
    func deleteAllTransactions() -> Bool {
        let fetchRequest = NSFetchRequest<HistoryCoreData>(entityName: "HistoryCoreData")
        
        do {
            let transactions = try context.fetch(fetchRequest)
            for transaction in transactions {
                context.delete(transaction)
            }
            try context.save()
            return true
        } catch {
            print("Error deleting all transactions: \(error)")
            return false
        }
    }
}
