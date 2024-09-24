//
//  ContractManager.swift
//  Mena App
//
//  Created by Shoaib_iOSDeveloper on 04/07/2024.
//  Copyright © 2024 Shoaib. All rights reserved.
//

import Foundation

import CoreData
import UIKit

class ContractManager {
    let context: NSManagedObjectContext
    
    init() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        context = appDelegate.context
    }
    
    // Create
    func createContracts(_ contracts: [Contracts]) -> Bool {
        for contract in contracts {
            let newContract = ContractData(context: context)
            newContract.address = contract.address ?? ""
            newContract.currency = contract.currency ?? ""
            newContract.currencyName = contract.currencyName ?? ""
            newContract.currencyRate = Double(contract.currencyRate ?? "0.0") ?? 0.0
            newContract.decimalCount = Int64(Int16(contract.decimalCount ?? 0))
        }
        
        do {
            try context.save()
            return true
        } catch {
            print("Error creating contracts: \(error)")
            return false
        }
    }
    
    // Read
    func fetchContracts() -> [Contracts]? {
        let fetchRequest = NSFetchRequest<ContractData>(entityName: "ContractData")
        
        do {
            let contracts = try context.fetch(fetchRequest)
            let contractList = contracts.map { $0.toContracts() }
            return contractList
        } catch {
            print("Error fetching contracts: \(error)")
            return nil
        }
    }
    
    // Update
    func updateContract(_ contract: Contracts) -> Bool {
        let fetchRequest: NSFetchRequest<ContractData> = ContractData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "address == %@", contract.address ?? "")
        
        do {
            let result = try context.fetch(fetchRequest)
            if let existingContract = result.first {
                existingContract.address = contract.address
                existingContract.currency = contract.currency
                existingContract.currencyName = contract.currencyName
                existingContract.currencyRate = Double(contract.currencyRate ?? "0.0") ?? 0.0
                existingContract.decimalCount = Int64(Int16(contract.decimalCount ?? 0))
                
                try context.save()
                return true
            } else {
                print("Contract not found")
                return false
            }
        } catch {
            print("Error updating contract: \(error)")
            return false
        }
    }
    
    // Delete
    func deleteContract(_ contract: Contracts) -> Bool {
        let fetchRequest: NSFetchRequest<ContractData> = ContractData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "address == %@", contract.address ?? "")
        
        do {
            let result = try context.fetch(fetchRequest)
            if let existingContract = result.first {
                context.delete(existingContract)
                try context.save()
                return true
            } else {
                print("Contract not found")
                return false
            }
        } catch {
            print("Error deleting contract: \(error)")
            return false
        }
    }
    
    // Delete All
    func deleteAllContracts() -> Bool {
        let fetchRequest = NSFetchRequest<ContractData>(entityName: "ContractData")
        
        do {
            let contracts = try context.fetch(fetchRequest)
            for contract in contracts {
                context.delete(contract)
            }
            try context.save()
            return true
        } catch {
            print("Error deleting all contracts: \(error)")
            return false
        }
    }
}
