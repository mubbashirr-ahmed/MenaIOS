//
//  CountryManager.swift
//  Mena App
//
//  Created by Shoaib_iOSDeveloper on 06/07/2024.
//  Copyright © 2024 Shoaib. All rights reserved.
//

import Foundation
import CoreData
import UIKit

class CountryManager {
    let context: NSManagedObjectContext
    
    init() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        context = appDelegate.context
    }
    
    // Create
    func createCountries(_ countries: [Countries]) -> Bool {
        for country in countries {
            let newCountry = CountryCoreData(context: context)
            newCountry.country = country.country
        }
        
        do {
            try context.save()
            return true
        } catch {
            print("Error creating countries: \(error)")
            return false
        }
    }
    
    // Read
    func fetchCountries() -> [Countries]? {
        let fetchRequest = NSFetchRequest<CountryCoreData>(entityName: "CountryCoreData")
        
        do {
            let countries = try context.fetch(fetchRequest)
            let countryList = countries.map { $0.toCountry() }
            return countryList
        } catch {
            print("Error fetching countries: \(error)")
            return nil
        }
    }
    
    // Delete All
    func deleteAllCountries() -> Bool {
        let fetchRequest = NSFetchRequest<CountryCoreData>(entityName: "CountryCoreData")
        
        do {
            let countries = try context.fetch(fetchRequest)
            for country in countries {
                context.delete(country)
            }
            try context.save()
            return true
        } catch {
            print("Error deleting all countries: \(error)")
            return false
        }
    }
}

