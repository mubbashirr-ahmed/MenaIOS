//
//  RefillManager.swift
//  Mena App
//
//  Created by Shoaib_iOSDeveloper on 07/07/2024.
//  Copyright © 2024 Shoaib. All rights reserved.
//

import Foundation
import CoreData
import UIKit

class RefillManager {
    let context: NSManagedObjectContext
    
    init() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        context = appDelegate.context
    }
    
    // Create
    func createBankRefillResponse(_ response: BankRefillResponse) -> Bool {
        let newResponse = RefillCoreData(context: context)
        newResponse.result = response.result
        newResponse.date = Date()
        
        do {
            try context.save()
            return true
        } catch {
            print("Error creating bank refill response: \(error)")
            return false
        }
    }
    
    // Read
    func fetchBankRefillResponses() -> [BankRefillResponse]? {
        let fetchRequest = NSFetchRequest<RefillCoreData>(entityName: "RefillCoreData")
        
        do {
            let responses = try context.fetch(fetchRequest)
            let responseList = responses.map { $0.toRefillResponse() }
            return responseList
        } catch {
            print("Error fetching bank refill responses: \(error)")
            return nil
        }
    }
    
    // Delete All
    func deleteAllBankRefillResponses() -> Bool {
        let fetchRequest = NSFetchRequest<RefillCoreData>(entityName: "RefillCoreData")
        
        do {
            let responses = try context.fetch(fetchRequest)
            for response in responses {
                context.delete(response)
            }
            try context.save()
            return true
        } catch {
            print("Error deleting all bank refill responses: \(error)")
            return false
        }
    }
}
