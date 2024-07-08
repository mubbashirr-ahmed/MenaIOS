//
//  MenaWalletManager.swift
//  Mena App
//
//  Created by Shoaib_iOSDeveloper on 07/07/2024.
//  Copyright © 2024 Shoaib. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class MenaWalletManager {
    let context: NSManagedObjectContext
    var menaWalletBalance: Double?

    init() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        context = appDelegate.context
    }

    // Update mena wallet balance
     func updateMenaWalletBalance(_ balance: Double) -> Bool {
         let fetchRequest = NSFetchRequest<WalletBalance>(entityName: "WalletBalance")
         fetchRequest.fetchLimit = 1 // assuming you only have one row for mena wallet balance

         do {
             let responses = try context.fetch(fetchRequest)
             if let existingResponse = responses.first {
                 existingResponse.mena_wallet_balance = balance
                 try context.save()
                 menaWalletBalance = balance
                 return true
             } else {
                 // create a new row if none exists
                 let newResponse = WalletBalance(context: context)
                 newResponse.mena_wallet_balance = balance
                 try context.save()
                 menaWalletBalance = balance
                 return true
             }
         } catch {
             print("Error updating mena wallet balance: \(error)")
             return false
         }
     }
    
    func fetchMenaWalletBalance() -> Double? {
        let fetchRequest = NSFetchRequest<WalletBalance>(entityName: "WalletBalance")
        fetchRequest.fetchLimit = 1 // assuming you only have one row for mena wallet balance

        do {
            let responses = try context.fetch(fetchRequest)
            if let existingResponse = responses.first {
                return existingResponse.mena_wallet_balance
            } else {
                return nil
            }
        } catch {
            print("Error fetching mena wallet balance: \(error)")
            return nil
        }
    }

     // Set mena wallet balance
     func setMenaWalletBalance(_ balance: Double) {
         menaWalletBalance = balance
     }

     // Get mena wallet balance
     func getMenaWalletBalance() -> Double? {
         return menaWalletBalance
     }
}
