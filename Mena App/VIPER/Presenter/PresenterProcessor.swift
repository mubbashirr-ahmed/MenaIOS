//
//  PresenterProcessor.swift
//  Mena App
//
//  Created by Shoaib_iOSDeveloper on 08/06/2024.
//  Copyright © 2024 Shoaib. All rights reserved.
//

import Foundation

class PresenterProcessor {
    
    static let shared = PresenterProcessor()
    
    func signUp(api : Base , data : Data)-> SignUpResponse{
        return data.getDecodedObject(from: SignUpResponse.self)!
    }
    
    func getTransactionHistory(api: Base, data: Data)-> History{
        return data.getDecodedObject(from: History.self)!
    }
    
    func getContract(api: Base, data: Data)->[Contracts]{
        return data.getDecodedObject(from: [Contracts].self) ?? []
    }
    func getCurrencyCountry(api: Base, data: Data)->CountryCurrency{
        return data.getDecodedObject(from: CountryCurrency.self)!
    }
    func getBankRefillResponse(api: Base, data: Data)->BankRefillResponse{
        return data.getDecodedObject(from: BankRefillResponse.self)!
    }
    
    func transactionResponse(api: Base, data: Data)->TrransactionResponse{
        return data.getDecodedObject(from: TrransactionResponse.self)!
    }
}
