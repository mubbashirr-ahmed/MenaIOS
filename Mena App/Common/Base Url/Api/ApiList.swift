//
//  ApiList.swift
//  Mena App
//
//  Created by Shoaib_iOSDeveloper on 08/06/2024.
//  Copyright © 2024 Shoaib. All rights reserved.
//

import Foundation

enum HttpType : String{
    
    case GET = "GET"
    case POST = "POST"
    case PATCH = "PATCH"
    case PUT = "PUT"
    case DELETE = "DELETE"
}

// Status Code

enum StatusCode : Int {
    
    case notreachable = 0
    case success = 200
    case multipleResponse = 300
    case unAuthorized = 401
    case notFound = 404
    case ServerError = 500
}

enum Base : String{
    
    case signUp = "accounts/register/mena"
    case menaHistory = "api/mena/address/transactions/mena/history"
    case tokenHistory = "api/mena/address/transactions/tokens/history"
    case contract = "contractsaddresses-menaapp"
    case countryCurrency = "countrycurrency-menaapp"
    case createTrade = "trade/create-otctrade-menaapp"
    case bankDetail = "accounts/otc-update-menaapp"
    case coinTransactionSend = "api/mena/transactions/mena/send-transaction"
    case tokenTransactionSend = "api/mena/transactions/token/send-transaction"
    
    init(fromRawValue: String){
        self = Base(rawValue: fromRawValue) ?? .signUp
    }
    
    static func valueFor(Key : String?)->Base{
        
        guard let key = Key else {
            return Base.signUp
        }
        
        if let base = Base(rawValue: key) {
            return base
        }
        
        return Base.signUp
        
    }
    var baseUrl: String {
            switch self {
            case .signUp, .contract, .countryCurrency, .createTrade, .bankDetail:
                return "https://apip1.menawalletapp.com"
            case .menaHistory, .tokenHistory, .coinTransactionSend, .tokenTransactionSend:
                return "https://apic2.menawalletapp.com"
            }
        }
        
        // A computed property to get the full URL
        var fullUrl: String {
            return "\(baseUrl)/"
        }
    
}
