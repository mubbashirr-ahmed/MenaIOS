//
//  CurrencyManager.swift
//  Mena App
//
//  Created by Shoaib_iOSDeveloper on 06/07/2024.
//  Copyright © 2024 Shoaib. All rights reserved.
//

import Foundation
import CoreData
import UIKit

class CurrencyManager {
    let context: NSManagedObjectContext
    
    init() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        context = appDelegate.context
    }
    
    // Create
    func createCurrencies(_ currencies: [Currencies]) -> Bool {
        for currency in currencies {
            let newCurrency = CurrencyCoreData(context: context)
            newCurrency.fiatCurrency = currency.fiatCurrency
        }
        
        do {
            try context.save()
            return true
        } catch {
            print("Error creating currencies: \(error)")
            return false
        }
    }
    
    // Read
    func fetchCurrencies() -> [Currencies]? {
        let fetchRequest = NSFetchRequest<CurrencyCoreData>(entityName: "CurrencyCoreData")
        
        do {
            let currencies = try context.fetch(fetchRequest)
            let currencyList = currencies.map { $0.toCurrency() }
            return currencyList
        } catch {
            print("Error fetching currencies: \(error)")
            return nil
        }
    }
    
    // Delete All
    func deleteAllCurrencies() -> Bool {
        let fetchRequest = NSFetchRequest<CurrencyCoreData>(entityName: "CurrencyData")
        
        do {
            let currencies = try context.fetch(fetchRequest)
            for currency in currencies {
                context.delete(currency)
            }
            try context.save()
            return true
        } catch {
            print("Error deleting all currencies: \(error)")
            return false
        }
    }
}

