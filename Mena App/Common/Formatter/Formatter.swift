//
//  Formatter.swift
//  Mena App
//
//  Created by Shoaib_iOSDeveloper on 02/07/2024.
//  Copyright © 2024 Shoaib. All rights reserved.
//

import Foundation
class Formatter {
    
    static let shared = Formatter()
    private var dateFormatter : DateFormatter?
    private var numberFormatter : NumberFormatter?
    
    // Initializing the Date formatter for the First Time
    private func initializeDateFormatter(){
        
        if self.dateFormatter == nil {
            dateFormatter = DateFormatter()
        }
    }

    // Getting String for Date with required format
    
    func getString(from date : Date?, format : String)->String?{
        
        initializeDateFormatter()
        dateFormatter?.locale = Locale(identifier:"UTC")
        dateFormatter?.dateFormat = format
        return date == nil ? nil : dateFormatter?.string(from: date!)
    }
    
    func forTrailingZero(temp: Float) -> String {
        var tempVar = ""
        tempVar = String(format: "%g", temp)
        return tempVar
    }
    
    // Getting Date from String Format
    
    func getDate(from string : String?, format : String)->Date?{
        
        initializeDateFormatter()
        dateFormatter?.dateFormat = format
        return string == nil ? nil : dateFormatter?.date(from: string!)
    }
    
    func formatDateString(_ dateString: String) -> String? {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "UTC")
        dateFormatter.dateFormat = "yyyy-MM-dd"
        guard let date = dateFormatter.date(from: dateString) else { return nil }
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        dateFormatter.dateFormat = "MMM dd, yyyy hh:mm:ss a"
        return dateFormatter.string(from: date)
    }
    
    func formatISO8601Date(_ dateString: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
//        dateFormatter.locale = Locale(identifier: "UTC")
//        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        if let date = dateFormatter.date(from: dateString) {
            dateFormatter.dateFormat = "dd MMM yyyy hh:mm a"
            return dateFormatter.string(from: date)
        } else {
            return "Invalid date string"
        }
    }
    //MARK:- Initilizing Number Formatter
    
    private func initializeNumberFormatter(){
        
        if numberFormatter == nil {
            self.numberFormatter = NumberFormatter()
        }
    }
    
    // MARK:- Limit number to required Decimal Values
    
    func limit(string number : String?, maximumDecimal limit : Int)->String{
        
        //initializeNumberFormatter()
        guard let float = Float(number ?? .Empty) else {
            return .Empty
        }
        var amount = String(format: "%.\(limit)f", float)
        
       return amount

    }
   
    
    // Make Minimum digits
    
    func makeMinimum(number : NSNumber, digits : Int)->String {
        
        initializeNumberFormatter()
        numberFormatter!.minimumIntegerDigits = digits
        return numberFormatter!.string(from: number) ?? .Empty
    }
    
    //Remove Decimal values from Number
    
    func removeDecimal(from number : Double)->Int?{
        
        initializeNumberFormatter()
        numberFormatter?.numberStyle = .none
        return numberFormatter?.number(from: "\(round(number))") as? Int
    }
    
    // Date to String
    
    
    
}
